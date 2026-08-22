// TIMELOOP — Engine
// Kernidee: Der reale Spieler-Input pro Tick wird als actionLog aufgezeichnet.
// Reist der Spieler in die Vergangenheit zurück und handelt dort ANDERS, wird
// der bisherige "Rest der Zukunft" als Zeitkopie (Clone) eingefroren, die den
// alten Weg exakt wiederholt — während der echte Spieler ab jetzt neu handelt.
// Die komplette Zeitlinie wird bei jeder Änderung deterministisch von Tick 0
// neu simuliert (Weltzustand = Funktion der Zeit, siehe Design-Doc §34).

function key(x, y) { return x + "," + y; }

class TimelineEngine {
  constructor(level) {
    this.level = JSON.parse(JSON.stringify(level));
    this.wallSet = new Set(this.level.walls);
    this.reset();
  }

  reset() {
    this.actionLog = [];      // actionLog[tick] = {type:'move',dx,dy} | {type:'interact'} | {type:'wait'}
    this.clones = [];         // {spawnTick, actions:[...]}
    this.maxTick = 0;
    this.currentTick = 0;
    this.stats = { travels: 0, resets: (this.stats ? this.stats.resets + 1 : 0), clonesUsed: 0 };
    this._resimulate();
  }

  // --- Öffentliche Steuerung -------------------------------------------------

  doAction(action) {
    if (this.currentTick < this.maxTick) {
      // Divergenz: alte Zukunft wird zur Zeitkopie eingefroren.
      const oldFuture = this.actionLog.slice(this.currentTick, this.maxTick);
      if (oldFuture.length > 0) {
        this.clones.push({ spawnTick: this.currentTick, actions: oldFuture });
        this.stats.clonesUsed++;
      }
      // Zukunft jenseits des aktuellen Zeitpunkts verwerfen (Vergangenheit verändert!).
      this.actionLog = this.actionLog.slice(0, this.currentTick);
      this.clones = this.clones.filter(c => c.spawnTick <= this.currentTick);
    }
    this.actionLog.push(action);
    this.currentTick++;
    this.maxTick = this.currentTick;
    this._resimulate();
  }

  move(dx, dy) { this.doAction({ type: "move", dx, dy }); }
  interact() { this.doAction({ type: "interact" }); }
  wait() { this.doAction({ type: "wait" }); }

  rewind() {
    if (this.currentTick > 0) { this.currentTick--; this.stats.travels++; }
  }
  forward() {
    if (this.currentTick < this.maxTick) { this.currentTick++; this.stats.travels++; }
  }
  scrubTo(tick) {
    tick = Math.max(0, Math.min(this.maxTick, tick));
    if (tick !== this.currentTick) this.stats.travels++;
    this.currentTick = tick;
  }

  get snapshot() { return this.snapshots[this.currentTick]; }
  isWon() { return !!this.everWon; }

  // --- Simulation --------------------------------------------------------

  _resimulate() {
    const lvl = this.level;
    const state = {
      player: { ...lvl.playerStart },
      heldKey: null,
      doors: {},
      switchesActive: {},
      boxes: {},
      keysTaken: {},
      npc: lvl.npc ? { ...lvl.npc.start, taken: false, alive: true } : null,
      won: false,
    };
    for (const b of lvl.boxes) state.boxes[b.id] = { x: b.x, y: b.y };
    for (const d of lvl.doors) state.doors[d.id] = false;

    const snapshots = [this._snap(state, [])];

    const isBlocked = (x, y, boxIgnoreId, tick) => {
      if (x < 0 || y < 0 || x >= lvl.cols || y >= lvl.rows) return true;
      if (this.wallSet.has(key(x, y))) return true;
      for (const d of lvl.doors) {
        if (d.x === x && d.y === y && !state.doors[d.id]) return true;
      }
      for (const id in state.boxes) {
        if (id === boxIgnoreId) continue;
        const b = state.boxes[id];
        if (b.x === x && b.y === y) return true;
      }
      return false;
    };

    const tryMove = (entity, dx, dy) => {
      const nx = entity.x + dx, ny = entity.y + dy;
      // Kiste im Weg?
      let pushedBoxId = null;
      for (const id in state.boxes) {
        const b = state.boxes[id];
        if (b.x === nx && b.y === ny) { pushedBoxId = id; break; }
      }
      if (pushedBoxId) {
        const bx = nx + dx, by = ny + dy;
        if (isBlocked(bx, by, pushedBoxId, null)) return; // Kiste kann nicht weiter -> blockiert
        state.boxes[pushedBoxId] = { x: bx, y: by };
        if (!isBlocked(nx, ny, pushedBoxId, null)) { entity.x = nx; entity.y = ny; }
        return;
      }
      if (!isBlocked(nx, ny, null, null)) { entity.x = nx; entity.y = ny; }
    };

    const activeClonesAtTick = [];

    for (let t = 1; t <= this.maxTick; t++) {
      // 1) NPC (skriptiert)
      if (state.npc && state.npc.alive && lvl.npc.moves[t - 1]) {
        const m = lvl.npc.moves[t - 1];
        if (m.action === "interact") {
          for (const k of lvl.keys) {
            if (!state.keysTaken[k.id] && k.x === state.npc.x && k.y === state.npc.y) {
              state.keysTaken[k.id] = "npc";
              state.npc.taken = true;
            }
          }
        } else if (m.dx !== undefined) {
          tryMove(state.npc, m.dx, m.dy);
        }
      }

      // 2) Zeitkopien
      for (const c of this.clones) {
        const idx = t - 1 - c.spawnTick;
        if (idx < 0) continue;
        if (!c._pos) c._pos = this._posAtTick(snapshots, c.spawnTick);
        if (idx < c.actions.length) {
          const a = c.actions[idx];
          if (a.type === "move") tryMove(c._pos, a.dx, a.dy);
          else if (a.type === "interact") this._applyInteract(state, c._pos, lvl);
        }
      }

      // 3) echter Spieler
      const a = this.actionLog[t - 1] || { type: "wait" };
      if (a.type === "move") tryMove(state.player, a.dx, a.dy);
      else if (a.type === "interact") this._applyInteract(state, state.player, lvl);

      // 4) Schalter (druckbasiert, jeden Tick neu berechnet). Eine Zeitkopie
      // bleibt nach Abspielen ihrer letzten Aktion an Ort und Stelle stehen.
      const bodies = [state.player, ...this.clones.filter(c => c._pos).map(c => c._pos)];
      for (const sw of lvl.switches) {
        state.switchesActive[sw.id] = bodies.some(b => b.x === sw.x && b.y === sw.y);
      }

      // 5) Türen aktualisieren
      for (const d of lvl.doors) {
        if (state.doors[d.id]) continue; // bleibt offen
        if (d.requires.type === "switches") {
          state.doors[d.id] = d.requires.ids.every(id => state.switchesActive[id]);
        } else if (d.requires.type === "key") {
          // key-Türen öffnen nur durch bewusstes Interact (siehe _applyInteract)
        } else if (d.requires.type === "boxOn") {
          const b = state.boxes[d.requires.boxId];
          state.doors[d.id] = !!b && b.x === d.requires.plateX && b.y === d.requires.plateY;
        }
      }

      // 6) Ziel erreicht?
      if (state.player.x === lvl.goal.x && state.player.y === lvl.goal.y) state.won = true;

      const clonePositions = this.clones.filter(c => c._pos).map(c => ({ x: c._pos.x, y: c._pos.y }));
      snapshots.push(this._snap(state, clonePositions));
    }

    this.snapshots = snapshots;
    this.everWon = snapshots.some(s => s.won);
    // Zwischenspeicher der Klon-Positionen für nächste Simulation entfernen
    for (const c of this.clones) delete c._pos;
  }

  _applyInteract(state, entity, lvl) {
    // Schlüssel aufnehmen
    for (const k of lvl.keys) {
      if (!state.keysTaken[k.id] && k.x === entity.x && k.y === entity.y) {
        state.keysTaken[k.id] = "player";
        state.heldKey = k.id;
        return;
      }
    }
    // Tür mit Schlüssel öffnen (Spieler muss direkt davorstehen)
    for (const d of lvl.doors) {
      if (state.doors[d.id]) continue;
      if (d.requires.type !== "key") continue;
      const adjacent = Math.abs(d.x - entity.x) + Math.abs(d.y - entity.y) === 1;
      const onTile = d.x === entity.x && d.y === entity.y;
      if ((adjacent || onTile) && state.heldKey === d.requires.keyId) {
        state.doors[d.id] = true;
      }
    }
  }

  _posAtTick(snapshots, tick) {
    const s = snapshots[Math.min(tick, snapshots.length - 1)];
    return { x: s.player.x, y: s.player.y };
  }

  _snap(state, clonePositions) {
    return JSON.parse(JSON.stringify({
      player: state.player,
      heldKey: state.heldKey,
      doors: state.doors,
      switchesActive: state.switchesActive,
      boxes: state.boxes,
      keysTaken: state.keysTaken,
      npc: state.npc,
      won: state.won,
      clonePositions,
    }));
  }

  // Positionen aller aktiven Zeitkopien zum aktuell angezeigten Tick (fürs Rendering)
  clonePositionsAt(tick) {
    return this.snapshots[tick].clonePositions;
  }
}
