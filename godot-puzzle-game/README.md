# Puzzle Realm

Ein hardcore Puzzle-Game für Mobile Geräte, entwickelt mit Godot 4.7.2.

Inspiriert von Take Two und Hollow Knight kombiniert das Spiel komplexe Puzzle-Mechaniken mit Action-Elements.

## Features

- ✨ **3 Level** mit progressivem Schwierigkeitsgrad
- 🎮 **Einfache Controls**: WASD zum Bewegen, Space zum Springen, Shift für Dash
- 🧩 **Puzzle-Mechanic**: Druckplatten zum Öffnen von Türen
- 👾 **Verschiedene Enemies**: Blob, Spike, Flying
- 🎨 **Shader & Visuelle Effekte**: Glow-Effekte, Damage-Flash
- 🔊 **Audio System**: Musik und Sound Effects Manager
- 📱 **Mobile Optimiert**: 540x960 Viewport für Handy-Spiele

## Spielweise

1. Starten Sie das Spiel mit der Main Menu Szene
2. Bewegen Sie den Charakter mit WASD
3. Lösen Sie Rätsel, indem Sie auf die blauen Platten treten
4. Vermeiden Sie Enemies und sammeln Sie Punkte
5. Erreichen Sie das Ziel am Ende jedes Levels

## Projekt-Struktur

```
godot-puzzle-game/
├── assets/
│   ├── sprites/
│   ├── ui/
│   └── tiles/
├── audio/
│   ├── music/
│   └── sfx/
├── scenes/
│   ├── characters/
│   ├── levels/
│   ├── ui/
│   └── effects/
├── scripts/
│   ├── player.gd
│   ├── enemy.gd
│   ├── puzzle_tile.gd
│   ├── door.gd
│   ├── game_manager.gd
│   ├── ui.gd
│   ├── audio_manager.gd
│   └── sprite_generator.gd
└── shaders/
    ├── player.gdshader
    ├── puzzle_tile.gdshader
    └── damage.gdshader
```

## Controls

- **A/D oder Arrow Left/Right**: Bewegen
- **W oder Arrow Up**: Springen
- **S oder Arrow Down**: Crouch
- **Shift/Lclick**: Dash
- **Space**: Interaktion

## Technologie

- **Engine**: Godot 4.7.2
- **Sprache**: GDScript
- **Platform**: Mobile (Android/iOS)
- **Auflösung**: 540x960 (Handy)

## Version

0.1.0 - Alpha Release
