# TIMELOOP — Spielbarer Prototyp

Ein Zeitreise-Puzzle-Game fürs Smartphone, gebaut als MVP nach dem
Design-Dokument (siehe Abschnitt 35 „MVP – erste spielbare Version“).
Reines Vanilla-HTML/CSS/JS, kein Build-Schritt nötig.

## Spielen

Einfach `index.html` in einem Browser öffnen (am besten mit einem lokalen
Server, damit relative Pfade sauber laden), z. B.:

```
cd timeloop
python3 -m http.server 8080
```

Dann `http://localhost:8080` öffnen. Für den mobilen Look das
Browser-Devtools-Gerätemodell (z. B. iPhone) verwenden — das Spiel ist
Hochformat/Mobile-First designed, funktioniert aber auch per Maus/Tastatur
(Pfeiltasten = Bewegen, Leertaste = Interagieren, Z/X = Zeit zurück/vor,
R = Reset).

## Umgesetzte Kernmechanik

- **Zeitlinie**: Jede Bewegung/Interaktion/Warten verbraucht genau einen
  „Tick“. Die komplette Levelgeschichte wird bei jeder Änderung
  deterministisch von Tick 0 neu simuliert (Weltzustand = Funktion der
  Zeit, siehe Design-Doc §34) — Türen, Schalter, Kisten und Schlüssel haben
  also zu jedem Zeitpunkt einen eindeutigen, reproduzierbaren Zustand.
- **Zurückspulen / Vorspulen**: Wischen links/rechts auf dem Spielfeld,
  ⏪/⏩-Buttons oder direktes Ziehen an der Zeitleiste.
- **Vergangenheit verändern**: Reist man zurück und handelt dort anders,
  wird der bisherige „Rest der Zukunft“ automatisch zu einer **Zeitkopie**
  eingefroren, die exakt den alten Weg wiederholt — während man selbst ab
  diesem Punkt neu handelt. So entstehen die in §13/§14 beschriebenen
  Zeitkopien-Rätsel (mehrere Versionen des Spielers halten gleichzeitig
  Schalter).
- **RESET TIMELINE**: Ein Button, sofortiger Neustart des Levels (§17/§18).
- **Bewertung**: 1–3 Sterne nach Resets/Zeitreisen (§20), lokal gespeichert.
- **Autosave**: Fortschritt, Sterne und freigeschaltete Level liegen in
  `localStorage` (§28).

## Struktur

- `levels.js` — Level-Daten (Grid, Wände, Schalter, Türen, Kisten,
  Schlüssel, skriptierte NPCs).
- `engine.js` — `TimelineEngine`: die komplette Zeitsimulation
  (Zeitkopien-Divergenz, Kollisionen/Kisten-Schieben, Schalter/Türen).
- `game.js` — UI-Logik: Menüs, Canvas-Rendering, Touch-/Tastatur-Steuerung,
  Speicherstand.
- `index.html` / `style.css` — Bildschirme (Menü, Levelauswahl,
  Einstellungen, Spiel) im dunklen, minimalistischen Look aus dem
  Design-Dokument (§5), inkl. der festgelegten Farbbedeutungen
  (Blau = Spieler, Lila = Zeitmechanik, Grün = aktivierbar, Rot = Gefahr,
  Gelb = wichtige Objekte).
- `test.js` — Node-Regressionstest, der jedes Level headless durchspielt
  (`node test.js`). Prüft insbesondere, dass jedes Rätsel **nicht** durch
  einen ungewollten Umweg trivial lösbar ist, und dass die vorgesehene
  Lösung tatsächlich zum Sieg führt.

## Level (Kapitel 1–3)

1. **Erste Schritte** — Bewegung, Interagieren, ein Schalter.
2. **Der Schlüssel** — Zeitreise nötig: die Wache nimmt sonst den
   Schlüssel zuerst.
3. **Die Kiste** — Kiste auf eine Druckplatte schieben, um eine Lücke in
   der Wand zu öffnen.
4. **Zwei Schalter** — Erste Zeitkopie: ein Schalter bleibt dauerhaft
   durch das vergangene Ich besetzt.
5. **Kettenschluss** — Kiste, Schalter, Schlüssel und zweite Tür in
   Kombination.
6. **Die Schleife** — Zwei gleichzeitige Zeitkopien für drei Schalter.

## Nicht im MVP enthalten

Gemäß §35 bewusst ausgeklammert: großes Story-/Terminal-System, Sound/
Musik, Paradoxien (Kapitel 5+), instabile Zeitzonen (Kapitel 6),
Querformat-Support. Die Engine ist aber so gebaut (objektbasierte
Weltzustände pro Tick, beliebig viele Zeitkopien), dass sich diese
Erweiterungen später draufsetzen lassen, ohne das Kernsystem umzubauen.
