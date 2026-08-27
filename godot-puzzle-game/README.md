# Puzzle Realm

Ein Puzzle-Hardcore-Mobile-Game für Godot 4.7.2 — eine Mischung aus
**Unpacking/Take Two**-artigen Umgebungsrätseln und **Hollow-Knight**-artiger
Bewegung/Kampf (Dash, Sprung, Stomp-Angriff auf Gegner von oben).

Jede Grafik, jeder Sound und jeder Musiktrack in diesem Projekt ist
selbst generiert (Pixel-Art per Pillow-Skript, Chiptune-Audio per
Wellenform-Synthese) — keine externen Assets, keine Lizenzfragen.

## Verifiziert, nicht nur behauptet

Dieses Projekt wurde mit dem echten Godot-4.7.2-Editor-Binary (headless)
gebaut und getestet, nicht nur als Text geschrieben:

- Vollständiger Editor-Import-Durchlauf ohne Fehler/Warnungen
- Jede Szene einzeln headless geladen und auf Skriptfehler geprüft
- Physik-Smoke-Test: Spieler fällt korrekt auf den Boden, Laufen/Kollision
  funktionieren, Druckplatte öffnet die verknüpfte Tür, Gegnerkontakt kostet
  Leben, Levelziel löst den Levelwechsel aus
- **Web-Export tatsächlich exportiert, im echten Chromium gerendert und per
  Screenshot verifiziert** (Hauptmenü, laufendes Level mit HUD, Kamera-Follow,
  Gegner) — siehe `tools/screenshot_web.py`

Bei diesen Tests wurden mehrere echte Bugs gefunden und behoben, u.a.:
`move_and_slide()`-Fehlgebrauch (Godot-3-Syntax), Godot-3-Shader-Syntax
(`hint_color`), eine Druckplatte mit fester Kollision, die den Spieler wie
eine Wand blockierte, fehlende `layout_mode`-Properties, die UI-Elemente an
Position (0,0) statt zentriert rendern ließen, und Gegner-Kollisionen, die
Seitenkontakt-Schaden verhinderten.

## Features

- 🎮 **Mobile-first**: 540×960 Portrait-Viewport, virtuelle Touch-Steuerung
  (Steuerkreuz + Sprung + Dash) zusätzlich zu Tastatur/Gamepad
- 🧩 **Puzzle-Mechanik**: Druckplatten öffnen dauerhaft verknüpfte Türen
- ⚔️ **Hollow-Knight-Kampf**: Sprung + Dash-Bewegung, Stomp-Angriff (von oben
  auf Gegner springen tötet sie und lässt den Spieler abprallen), Seitenkontakt
  kostet Leben
- 👾 **3 Gegnertypen**: Blob (Bodenpatrouille), Spike (langsam, 2 Treffer),
  Flying (schwebt sinusförmig)
- 🎨 **3 GDShader**: Spieler-Puls + Schadens-Flash, Gegner-Hit-Flash,
  Puzzle-Tile-Glow
- 🔊 **Vollständiges Audiosystem**: 2 Musik-Loops (Menü/Level) + 9 SFX,
  alle synthetisch erzeugt
- 📈 **3 Level** mit steigendem Schwierigkeitsgrad (mehr Gegner, mehr Gates)

## Steuerung

| Aktion | Tastatur | Touch |
|---|---|---|
| Bewegen | A/D oder Pfeiltasten | Linker/rechter Button |
| Springen | Leertaste | Sprung-Button |
| Dash | Shift | Dash-Button |

## Projektstruktur

```
godot-puzzle-game/
├── assets/sprites/    Generierte Pixel-Art (Spieler, Gegner, BG)
├── assets/tiles/       Boden/Wand/Tür/Puzzle-Tile-Texturen
├── assets/ui/          Herzen, Stern, Touch-Buttons, Icon
├── audio/music/        2 generierte Loop-Tracks (.wav)
├── audio/sfx/          9 generierte Soundeffekte (.wav)
├── scenes/              Alle .tscn-Szenen (Charaktere, Level, UI)
├── scripts/              Gesamte Spiellogik (GDScript)
├── shaders/              3 GDShader-Dateien
├── tools/                Python-Skripte zum Neu-Generieren der Assets
│                         + Playwright-Screenshot-Test für den Web-Build
└── export_presets.cfg    Android- und Web-Export-Presets
```

## Selbst ausprobieren

**Im Godot-Editor:** Projekt öffnen (Godot **4.7.2**), F5 drücken.

**Assets neu generieren** (optional, z. B. nach Änderungen an den
Generator-Skripten):
```bash
pip install pillow numpy
python3 tools/gen_sprites.py
python3 tools/gen_tiles.py
python3 tools/gen_audio.py
```

**Als Web-Build exportieren und im Browser testen:**
```bash
godot4 --headless --export-debug "Web" export/web/index.html
cd export/web && python3 -m http.server 8791
# dann http://localhost:8791/index.html öffnen
```

**Als Android-APK exportieren:** Im Editor unter *Project → Export* das
vorbereitete "Android"-Preset wählen (Debug-Keystore wird von Godot
automatisch erzeugt, falls in den Editor-Einstellungen ein Android-SDK-Pfad
hinterlegt ist). Das Android-SDK selbst ist nicht Teil dieses Repos und muss
lokal installiert sein — in der Sandbox, in der dieses Projekt entwickelt
wurde, war der Zugriff auf die Google-Download-Server aus Policy-Gründen
gesperrt, weshalb der APK-Build dort nicht durchgeführt werden konnte. Der
Web-Export wurde als Ersatzverifikation exportiert, im echten Browser
gerendert und per Screenshot bestätigt.

## Bekannte Grenzen

- Nur 3 Level (leicht per neuer `.tscn`-Datei nach dem Muster von
  `level_1.tscn` erweiterbar)
- Kein persistenter Spielstand (Score/Level werden bei App-Neustart
  zurückgesetzt)
- Pixel-Art-Sprites sind bewusst simpel/minimalistisch gehalten, nicht
  hochauflösend
