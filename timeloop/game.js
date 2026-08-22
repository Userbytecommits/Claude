// TIMELOOP — UI, Rendering, Steuerung, Speicherstand

const COLORS = {
  player: "#3fa9ff",
  time: "#b06bff",
  active: "#38e07a",
  danger: "#ff4d5e",
  important: "#ffd23f",
  normal: "#cfd6e6",
  wall: "#232a4a",
};

// ---------- Speicherstand ----------
const SAVE_KEY = "timeloop_save_v1";
function loadSave() {
  try {
    return JSON.parse(localStorage.getItem(SAVE_KEY)) || { unlocked: 1, stars: {}, lastLevel: 1 };
  } catch (e) { return { unlocked: 1, stars: {}, lastLevel: 1 }; }
}
function saveSave(s) { localStorage.setItem(SAVE_KEY, JSON.stringify(s)); }
let save = loadSave();

// ---------- Screens ----------
function showScreen(id) {
  document.querySelectorAll(".screen").forEach(s => s.classList.remove("active"));
  document.getElementById(id).classList.add("active");
}
document.querySelectorAll("[data-back]").forEach(btn => {
  btn.addEventListener("click", () => showScreen(btn.dataset.back));
});

document.getElementById("btn-newgame").addEventListener("click", () => {
  save = { unlocked: 1, stars: {}, lastLevel: 1 };
  saveSave(save);
  startLevel(1);
});
document.getElementById("btn-continue").addEventListener("click", () => startLevel(save.lastLevel || 1));
document.getElementById("btn-levels").addEventListener("click", () => { renderLevelList(); showScreen("screen-levels"); });
document.getElementById("btn-settings").addEventListener("click", () => showScreen("screen-settings"));
document.getElementById("btn-clear-save").addEventListener("click", () => {
  if (confirm("Fortschritt wirklich löschen?")) {
    save = { unlocked: 1, stars: {}, lastLevel: 1 };
    saveSave(save);
    renderLevelList();
  }
});

function renderLevelList() {
  const list = document.getElementById("level-list");
  list.innerHTML = "";
  for (const lvl of LEVELS) {
    const locked = lvl.id > save.unlocked;
    const div = document.createElement("div");
    div.className = "level-card" + (locked ? " locked" : "");
    const stars = save.stars[lvl.id] || 0;
    div.innerHTML = `<div><span class="lname">${lvl.id}. ${lvl.name}</span>
      <span class="lchapter">Kapitel ${lvl.chapter}${locked ? " · gesperrt" : ""}</span></div>
      <div class="lstars">${locked ? "🔒" : "★".repeat(stars) + "☆".repeat(3 - stars)}</div>`;
    if (!locked) div.addEventListener("click", () => startLevel(lvl.id));
    list.appendChild(div);
  }
}

// ---------- Spiel-Zustand ----------
let engine = null;
let currentLevel = null;
let cellSize = 48;

function startLevel(id) {
  winShown = false;
  currentLevel = LEVELS.find(l => l.id === id);
  engine = new TimelineEngine(currentLevel);
  save.lastLevel = id;
  saveSave(save);
  document.getElementById("level-title").textContent = `${id}. ${currentLevel.name}`;
  document.getElementById("hint-banner").textContent = currentLevel.hint;
  document.getElementById("win-overlay").classList.add("hidden");
  showScreen("screen-game");
  resizeCanvas();
  render();
}

document.getElementById("btn-exit-level").addEventListener("click", () => { renderLevelList(); showScreen("screen-levels"); });
document.getElementById("btn-reset").addEventListener("click", () => {
  engine.reset();
  document.getElementById("win-overlay").classList.add("hidden");
  render();
});
document.getElementById("btn-win-retry").addEventListener("click", () => {
  engine.reset();
  document.getElementById("win-overlay").classList.add("hidden");
  render();
});
document.getElementById("btn-win-next").addEventListener("click", () => {
  const next = LEVELS.find(l => l.id === currentLevel.id + 1);
  document.getElementById("win-overlay").classList.add("hidden");
  if (next) startLevel(next.id); else { renderLevelList(); showScreen("screen-levels"); }
});

// ---------- Canvas & Rendering ----------
const canvas = document.getElementById("game-canvas");
const ctx = canvas.getContext("2d");

function resizeCanvas() {
  const wrap = document.getElementById("canvas-wrap");
  const availW = wrap.clientWidth - 16;
  const availH = wrap.clientHeight - 16;
  const cols = currentLevel.cols, rows = currentLevel.rows;
  cellSize = Math.floor(Math.min(availW / cols, availH / rows));
  canvas.width = cellSize * cols;
  canvas.height = cellSize * rows;
}
window.addEventListener("resize", () => { if (currentLevel) { resizeCanvas(); render(); } });

function cellRect(x, y) { return [x * cellSize, y * cellSize, cellSize, cellSize]; }

function roundRect(x, y, w, h, r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.arcTo(x + w, y, x + w, y + h, r);
  ctx.arcTo(x + w, y + h, x, y + h, r);
  ctx.arcTo(x, y + h, x, y, r);
  ctx.arcTo(x, y, x + w, y, r);
  ctx.closePath();
}

function render() {
  const lvl = currentLevel;
  const snap = engine.snapshot;
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Boden
  ctx.fillStyle = "#0e1226";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = "rgba(255,255,255,0.03)";
  for (let x = 0; x <= lvl.cols; x++) { ctx.beginPath(); ctx.moveTo(x * cellSize, 0); ctx.lineTo(x * cellSize, canvas.height); ctx.stroke(); }
  for (let y = 0; y <= lvl.rows; y++) { ctx.beginPath(); ctx.moveTo(0, y * cellSize); ctx.lineTo(canvas.width, y * cellSize); ctx.stroke(); }

  // Wände
  ctx.fillStyle = COLORS.wall;
  for (const w of lvl.walls) {
    const [x, y] = w.split(",").map(Number);
    ctx.fillRect(...cellRect(x, y));
  }

  // Ziel
  const [gx, gy, gw, gh] = cellRect(lvl.goal.x, lvl.goal.y);
  ctx.strokeStyle = COLORS.active;
  ctx.lineWidth = 3;
  ctx.setLineDash([6, 4]);
  roundRect(gx + 4, gy + 4, gw - 8, gh - 8, 8);
  ctx.stroke();
  ctx.setLineDash([]);

  // Schalter
  for (const sw of lvl.switches) {
    const active = snap.switchesActive[sw.id];
    const [x, y, w, h] = cellRect(sw.x, sw.y);
    ctx.fillStyle = active ? COLORS.active : "rgba(56,224,122,0.25)";
    roundRect(x + 8, y + 8, w - 16, h - 16, 6);
    ctx.fill();
  }

  // Türen
  for (const d of lvl.doors) {
    const open = snap.doors[d.id];
    const [x, y, w, h] = cellRect(d.x, d.y);
    if (!open) {
      ctx.fillStyle = COLORS.danger;
      roundRect(x + 3, y + 3, w - 6, h - 6, 4);
      ctx.fill();
    } else {
      ctx.strokeStyle = "rgba(255,77,94,0.4)";
      ctx.lineWidth = 2;
      roundRect(x + 3, y + 3, w - 6, h - 6, 4);
      ctx.stroke();
    }
  }

  // Kisten
  for (const bid in snap.boxes) {
    const b = snap.boxes[bid];
    const [x, y, w, h] = cellRect(b.x, b.y);
    ctx.fillStyle = COLORS.important;
    roundRect(x + 6, y + 6, w - 12, h - 12, 6);
    ctx.fill();
    ctx.strokeStyle = "rgba(0,0,0,0.25)";
    ctx.strokeRect(x + 6, y + 6, w - 12, h - 12);
  }

  // Schlüssel
  for (const k of lvl.keys) {
    if (snap.keysTaken[k.id]) continue;
    const [x, y, w, h] = cellRect(k.x, k.y);
    ctx.fillStyle = COLORS.important;
    ctx.beginPath();
    ctx.arc(x + w / 2, y + h / 2, cellSize * 0.18, 0, Math.PI * 2);
    ctx.fill();
  }

  // NPC
  if (snap.npc) {
    const [x, y, w, h] = cellRect(snap.npc.x, snap.npc.y);
    ctx.fillStyle = COLORS.normal;
    roundRect(x + 10, y + 6, w - 20, h - 12, cellSize * 0.2);
    ctx.fill();
  }

  // Zeitkopien (Vergangenheits-Ich)
  for (const c of snap.clonePositions) {
    const [x, y, w, h] = cellRect(c.x, c.y);
    ctx.fillStyle = "rgba(176,107,255,0.55)";
    ctx.strokeStyle = COLORS.time;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(x + w / 2, y + h / 2, cellSize * 0.28, 0, Math.PI * 2);
    ctx.fill();
    ctx.stroke();
  }

  // Spieler
  {
    const [x, y, w, h] = cellRect(snap.player.x, snap.player.y);
    ctx.fillStyle = COLORS.player;
    ctx.shadowColor = COLORS.player;
    ctx.shadowBlur = 12;
    ctx.beginPath();
    ctx.arc(x + w / 2, y + h / 2, cellSize * 0.3, 0, Math.PI * 2);
    ctx.fill();
    ctx.shadowBlur = 0;
    if (snap.heldKey) {
      ctx.fillStyle = COLORS.important;
      ctx.beginPath();
      ctx.arc(x + w / 2 + cellSize * 0.22, y + h / 2 - cellSize * 0.22, cellSize * 0.1, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  updateTimelineUI();

  if (engine.isWon()) showWin();
}

function updateTimelineUI() {
  const track = document.getElementById("timeline-track");
  const fill = document.getElementById("timeline-fill");
  const cursor = document.getElementById("timeline-cursor");
  const len = Math.max(engine.maxTick, currentLevel.timelineLength);
  const pct = len === 0 ? 0 : (engine.currentTick / len) * 100;
  const fillPct = len === 0 ? 0 : (engine.maxTick / len) * 100;
  fill.style.width = fillPct + "%";
  cursor.style.left = pct + "%";
  const label = document.getElementById("time-label");
  if (engine.currentTick === engine.maxTick) label.textContent = "GEGENWART";
  else label.textContent = "VERGANGENHEIT · Tick " + engine.currentTick;
}

let winShown = false;
function showWin() {
  if (winShown) return;
  winShown = true;
  const overlay = document.getElementById("win-overlay");
  overlay.classList.remove("hidden");

  const s = engine.stats;
  let stars = 3;
  if (s.resets > 1) stars--;
  if (s.travels > (currentLevel.timelineLength * 1.5)) stars--;
  stars = Math.max(1, stars);

  document.getElementById("win-stars").textContent = "★".repeat(stars) + "☆".repeat(3 - stars);
  document.getElementById("win-stats").innerHTML =
    `Aktionen: ${engine.maxTick} &nbsp;·&nbsp; Zeitreisen: ${s.travels}<br/>Resets: ${s.resets} &nbsp;·&nbsp; Zeitkopien: ${s.clonesUsed}`;

  save.stars[currentLevel.id] = Math.max(save.stars[currentLevel.id] || 0, stars);
  save.unlocked = Math.max(save.unlocked, currentLevel.id + 1);
  saveSave(save);
}

// ---------- Aktionen ----------
function act(fn) {
  if (!engine || engine.isWon()) return;
  fn();
  render();
}

document.querySelectorAll(".dpad-btn").forEach(btn => {
  btn.addEventListener("click", () => act(() => engine.move(Number(btn.dataset.dx), Number(btn.dataset.dy))));
});
document.getElementById("btn-interact").addEventListener("click", () => act(() => engine.interact()));
document.getElementById("btn-rewind").addEventListener("click", () => act(() => engine.rewind()));
document.getElementById("btn-forward").addEventListener("click", () => act(() => engine.forward()));

// Timeline direkt per Finger scrubben
const timelineTrack = document.getElementById("timeline-track");
function scrubFromEvent(clientX) {
  const rect = timelineTrack.getBoundingClientRect();
  const pct = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width));
  const len = Math.max(engine.maxTick, currentLevel.timelineLength);
  act(() => engine.scrubTo(Math.round(pct * len)));
}
timelineTrack.addEventListener("touchstart", e => { scrubFromEvent(e.touches[0].clientX); }, { passive: true });
timelineTrack.addEventListener("touchmove", e => { scrubFromEvent(e.touches[0].clientX); }, { passive: true });
timelineTrack.addEventListener("mousedown", e => {
  scrubFromEvent(e.clientX);
  const onMove = ev => scrubFromEvent(ev.clientX);
  const onUp = () => { window.removeEventListener("mousemove", onMove); window.removeEventListener("mouseup", onUp); };
  window.addEventListener("mousemove", onMove);
  window.addEventListener("mouseup", onUp);
});

// Wischgesten auf dem Spielfeld: links/rechts = Zeit, zwei Finger = Pause(Warten)
let touchStartX = null, touchStartY = null, touchStartTime = 0;
canvas.addEventListener("touchstart", e => {
  if (e.touches.length === 2) {
    act(() => engine.wait());
    return;
  }
  touchStartX = e.touches[0].clientX;
  touchStartY = e.touches[0].clientY;
  touchStartTime = Date.now();
}, { passive: true });

canvas.addEventListener("touchend", e => {
  if (touchStartX === null) return;
  const dx = (e.changedTouches[0].clientX - touchStartX);
  const dy = (e.changedTouches[0].clientY - touchStartY);
  const dt = Date.now() - touchStartTime;
  const absX = Math.abs(dx), absY = Math.abs(dy);

  if (Math.max(absX, absY) < 12) {
    // Tap = Interact
    act(() => engine.interact());
  } else if (dt < 500 && absX > absY && absX > 40) {
    // horizontaler Swipe = Zeit
    if (dx < 0) act(() => engine.rewind()); else act(() => engine.forward());
  } else if (absY > absX && absY > 30) {
    act(() => engine.move(0, dy < 0 ? -1 : 1));
  } else if (absX > 30) {
    act(() => engine.move(dx < 0 ? -1 : 1, 0));
  }
  touchStartX = null;
}, { passive: true });

// Tastatur (Desktop-Test)
window.addEventListener("keydown", e => {
  if (!engine || !document.getElementById("screen-game").classList.contains("active")) return;
  switch (e.key) {
    case "ArrowUp": act(() => engine.move(0, -1)); break;
    case "ArrowDown": act(() => engine.move(0, 1)); break;
    case "ArrowLeft": act(() => engine.move(-1, 0)); break;
    case "ArrowRight": act(() => engine.move(1, 0)); break;
    case " ": act(() => engine.interact()); break;
    case "z": case "Z": act(() => engine.rewind()); break;
    case "x": case "X": act(() => engine.forward()); break;
    case "r": case "R": engine.reset(); render(); break;
  }
});

renderLevelList();
