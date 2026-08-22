const fs = require("fs");
const src = fs.readFileSync("levels.js", "utf8") + "\n" + fs.readFileSync("engine.js", "utf8") +
  "\nmodule.exports = { LEVELS, TimelineEngine };";
const mod = { exports: {} };
new Function("module", "exports", "console", src)(mod, mod.exports, console);
const { LEVELS, TimelineEngine } = mod.exports;

let failures = 0;
function expect(name, cond) {
  console.log((cond ? "PASS" : "FAIL") + " — " + name);
  if (!cond) failures++;
}
function newEngine(id) { return new TimelineEngine(LEVELS.find(l => l.id === id)); }
function walk(e, path) { for (const [dx, dy] of path) e.move(dx, dy); }

// ---- Level 1 ----
{
  const e = newEngine(1);
  // Direkter Weg (ohne Zeitreise) darf NICHT gewinnen — Tür ist zu.
  walk(e, [[1,0],[0,-1],[0,-1],[0,-1],[0,-1]]);
  expect("L1: ohne Schalter bleibt Tür zu (kein Sieg via Umweg)", !e.isWon());
  const e2 = newEngine(1);
  walk(e2, [[1,0],[0,-1],[0,-1],[-1,0],[0,-1],[0,-1],[0,-1]]); // zum Schalter, dann durch die Tür zum Ziel
  expect("L1: gewonnen über Schalter", e2.isWon());
}

// ---- Level 2 ----
{
  const e = newEngine(2);
  for (let i = 0; i < 6; i++) e.wait();
  expect("L2: Wache nimmt Schlüssel wenn Spieler wartet", e.snapshot.keysTaken["k1"] === "npc");
}
{
  const e = newEngine(2);
  walk(e, [[1,0],[1,0],[0,-1],[0,-1]]); // 1,5 -> 3,3 (Schlüssel), 4 Ticks
  expect("L2: Spieler bei Schlüssel vor Wache (Tick4)", e.snapshot.player.x === 3 && e.snapshot.player.y === 3);
  e.interact();
  expect("L2: Spieler hält Schlüssel", e.snapshot.heldKey === "k1");
  walk(e, [[1,0],[1,0]]); // 4,3 -> 5,3 (neben Tür)
  e.interact();
  expect("L2: Tür offen", e.snapshot.doors["d1"]);
  e.move(0, -1); // 5,3 -> 5,2
  e.move(0, -1); // 5,2 -> 5,1 Ziel
  expect("L2: gewonnen", e.isWon());
}
{
  // Ohne Zeitreise-Trick (Spieler bummelt, Wache holt Schlüssel zuerst) -> Tür bleibt zu
  const e = newEngine(2);
  for (let i = 0; i < 7; i++) e.wait();
  walk(e, [[1,0],[1,0],[0,-1],[0,-1],[1,0],[1,0]]);
  e.interact();
  expect("L2: ohne Schlüssel bleibt Tür zu", !e.snapshot.doors["d1"]);
}

// ---- Level 3: Kiste auf Druckplatte schieben ----
{
  const e = newEngine(3);
  // Direktversuch ohne Kiste zu bewegen darf nicht gewinnen
  walk(e, [[0,-1],[0,-1],[0,-1],[0,-1],[0,-1]]);
  expect("L3: ohne Kiste bleibt Lücke zu", !e.isWon());
}
{
  const e = newEngine(3);
  // Start (1,6), Kiste (4,5). Spieler geht neben die Kiste (5,5) und schiebt sie nach links auf Platte (1,5).
  walk(e, [[1,0],[1,0],[1,0],[1,0]]); // 1,6 -> 5,6
  walk(e, [[0,-1]]); // 5,6 -> 5,5 (rechts von Kiste)
  walk(e, [[-1,0],[-1,0],[-1,0]]); // schiebt Kiste 4,5->3,5->2,5->1,5 (Platte)
  expect("L3: Kiste auf Platte", e.snapshot.boxes["b1"].x === 1 && e.snapshot.boxes["b1"].y === 5);
  expect("L3: Lücke offen", e.snapshot.doors["dGap"]);
  // zum Ziel (3,1)
  walk(e, [[0,-1],[1,0],[0,-1],[0,-1],[0,-1]]); // grob Richtung Ziel, ggf. anpassen
  console.log("L3 Endposition:", JSON.stringify(e.snapshot.player), "won:", e.isWon());
}

// ---- Level 4 ----
{
  const e = newEngine(4);
  walk(e, [[-1,0],[0,-1],[-1,0],[0,-1]]); // zu swA (1,3)
  expect("L4: swA aktiv", e.snapshot.switchesActive["swA"]);
  e.scrubTo(0);
  walk(e, [[1,0],[0,-1],[1,0],[0,-1]]); // Divergenz: zu swB (5,3)
  expect("L4: swB aktiv", e.snapshot.switchesActive["swB"]);
  expect("L4: swA weiterhin aktiv (Zeitkopie)", e.snapshot.switchesActive["swA"]);
  expect("L4: Tür offen", e.snapshot.doors["d1"]);
  walk(e, [[-1,0],[-1,0],[0,-1],[0,-1]]); // 5,3 -> 3,3 -> Tür(3,2) -> Ziel(3,1)
  expect("L4: gewonnen", e.isWon());
}

// ---- Level 4: OHNE Zeitkopie darf man nicht gewinnen (Kontrollprobe) ----
{
  const e = newEngine(4);
  walk(e, [[-1,0],[0,-1],[-1,0],[0,-1]]); // nur swA
  expect("L4: nur ein Schalter reicht nicht", !e.snapshot.doors["d1"]);
}

// ---- Level 5: Kiste schieben, Schalter, Schlüssel, zweite Tür ----
{
  const e = newEngine(5);
  // Start (1,6), Kiste (1,5) direkt im 1-breiten Korridor. Dreimal hochschieben:
  // die Kiste wandert bis auf Feld (1,2), der Spieler landet dabei exakt auf dem Schalter (1,3).
  walk(e, [[0,-1],[0,-1],[0,-1]]);
  expect("L5: Spieler landet nach 3x Schieben auf dem Schalter", e.snapshot.player.x === 1 && e.snapshot.player.y === 3);
  expect("L5: Schalter aktiv", e.snapshot.switchesActive["swHold"]);
  expect("L5: Tor dGate offen", e.snapshot.doors["dGate"]);
  walk(e, [[1,0],[0,-1],[1,0],[1,0]]); // 1,3->2,3->2,2->3,2->4,2 (durchs Tor, Kiste bei 1,2 umgehen)
  walk(e, [[1,0],[0,1]]); // 4,2->5,2->5,3 (zum Schlüssel)
  expect("L5: Spieler bei Schlüssel", e.snapshot.player.x === 5 && e.snapshot.player.y === 3);
  e.interact();
  expect("L5: Schlüssel geholt", e.snapshot.heldKey === "k1");
  e.move(0, -1); // 5,3 -> 5,2
  e.interact(); // öffnet dMain (6,2), adjazent
  expect("L5: dMain offen", e.snapshot.doors["dMain"]);
  e.move(1, 0); // 5,2 -> 6,2
  e.move(0, -1); // 6,2 -> 6,1 Ziel
  expect("L5: gewonnen", e.isWon());
}

// ---- Level 6: drei Schalter, zwei Zeitkopien ----
{
  const e = newEngine(6);
  // Start (3,5). swA(1,4) swB(5,4) swC(3,3). Tür (3,2) braucht alle drei gleichzeitig.
  walk(e, [[-1,0],[0,-1]]); // 3,5->2,5->2,4? pruefen: erst links dann hoch -> (2,5)->(2,4)? need dx-1 dy-1 order
  // Weg zu swA: (3,5)->(2,5)->(1,5)->(1,4)
  const e1 = newEngine(6);
  walk(e1, [[-1,0],[-1,0],[0,-1]]); // 3,5->2,5->1,5->1,4 (swA)
  expect("L6: swA aktiv", e1.snapshot.switchesActive["swA"]);
  e1.scrubTo(0);
  walk(e1, [[1,0],[1,0],[0,-1]]); // Divergenz zu swB: 3,5->4,5->5,5->5,4
  expect("L6: swB aktiv (Divergenz1)", e1.snapshot.switchesActive["swB"]);
  expect("L6: swA weiterhin aktiv (Klon1)", e1.snapshot.switchesActive["swA"]);
  const tAfterB = e1.currentTick;
  e1.scrubTo(0);
  walk(e1, [[0,-1],[0,-1]]); // Divergenz zu swC: 3,5->3,4->3,3
  e1.wait(); // eine Wartetick, damit beide Zeitkopien ihren (3 Ticks langen) Weg beenden
  expect("L6: swC aktiv (Spieler)", e1.snapshot.switchesActive["swC"]);
  expect("L6: swA weiterhin aktiv (Klon1)", e1.snapshot.switchesActive["swA"]);
  expect("L6: swB weiterhin aktiv (Klon2)", e1.snapshot.switchesActive["swB"]);
  expect("L6: alle drei aktiv -> Tür offen", e1.snapshot.doors["d1"]);
  e1.move(0, -1); e1.move(0, -1);
  expect("L6: gewonnen", e1.isWon());
}

console.log(failures === 0 ? "\nALLE PFLICHTTESTS OK" : `\n${failures} TEST(S) FEHLGESCHLAGEN`);
process.exit(failures === 0 ? 0 : 1);
