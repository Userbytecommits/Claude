# Android Game Engine - Getting Started Guide

Willkommen! Diese Anleitung führt dich durch die Erstellung deines ersten Spiels in 30 Minuten.

## Installation

### Voraussetzungen
- Android SDK 21+ installiert
- Kotlin 1.9.22+
- Java 11+
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/android-game-engine.git
cd android-game-engine

# Build the engine
./gradlew :engine:build

# Launch the editor
./gradlew :editor:run
```

## Dein erstes Spiel: Flappy Bird Clone (30 Minuten)

### Schritt 1: Projekt erstellen (2 Minuten)

1. Öffne den Editor
2. Klick auf "New Project"
3. Gib den Namen ein: "My Flappy Bird"
4. Wähle Verzeichnis für das Projekt
5. ✓ Projekt erstellt!

### Schritt 2: Spieler erstellen (3 Minuten)

Im Editor:
1. **Scene Tree** → Klick "+ Add Entity"
2. Name: "Player"
3. Wähle: "SpriteComponent" aus "Add Component"
4. Inspector → Farbe: Gold (0xFFD700)
5. Klick "+ Add Component" → "RigidbodyComponent"
   - Mass: 1.0
   - Use Gravity: ✓ enabled
6. Klick "+ Add Component" → "BoxColliderComponent"
   - Width: 32
   - Height: 32

**Ergebnis**: Ein goldener Vogel mit Physik und Kollisionen!

### Schritt 3: Hindernisse (Pipes)

1. "+ Add Entity" → Name: "PipeSpawner"
2. RigidbodyComponent (Static)
3. BoxColliderComponent (64x512)
4. Inspector → Add Script: "PipeSpawner"
   - Spawn Interval: 0.3 seconds
   - Pipe Speed: 300 px/s
   - Pipe Gap: 150 px

**Ergebnis**: Pipes spawnen automatisch!

### Schritt 4: Input Setup (2 Minuten)

Tools → Input Settings:
- ✓ Touch Input enabled
- ✓ Space Key enabled

```kotlin
// Im Spiel
if (gameEngine.inputManager.isTouched() || 
    gameEngine.inputManager.isKeyPressed(KeyEvent.KEYCODE_SPACE)) {
    playerRigidbody.setVelocity(0f, -15f)  // Jump!
}
```

### Schritt 5: Collision Detection (3 Minuten)

```kotlin
gameEngine.physicsWorld.onCollision { entity1, entity2 ->
    if (entity1.name == "Player" || entity2.name == "Player") {
        println("Game Over!")
        gameEngine.loadScene(createGameOverScene())
    }
}
```

### Schritt 6: Test im Editor (5 Minuten)

1. Canvas → "Play" Button
2. Klick oder drück SPACE zum Springen
3. Ausweichen vor den Pipes!
4. Canvas → "Stop" Button

### Schritt 7: Als APK exportieren (7 Minuten)

Tools → Export to APK:
1. Package Name: `com.example.flappybird`
2. Version: 1.0.0
3. Icon: (optional)
4. Output: Wähle Download-Ordner
5. Build → APK generiert!
6. Auf Handy installieren: `adb install flappy-bird.apk`

**Gratuliert! Dein erstes Spiel läuft auf deinem Handy! 🎮**

---

## Grundkonzepte verstehen

### Entities (Objekte)

Alles in einem Spiel ist eine **Entity**:
```kotlin
val player = Entity("Player")
player.position = Vector2(540f, 960f)
player.rotation = 45f
player.scale = Vector2(1f, 1f)
```

### Components (Verhalten)

Components definieren was Entities **können**:

```kotlin
// Grafik rendern
player.addComponent(SpriteComponent())

// Physik simulieren
player.addComponent(RigidbodyComponent())

// Kollisionen erkennen
player.addComponent(BoxColliderComponent())
```

### Scenes (Level)

Scenes sind Level/Menü mit Entities:

```kotlin
val scene = Scene("MainGame")
scene.addEntity(player)
scene.addEntity(ground)
scene.addEntity(enemy)

gameEngine.loadScene(scene)
```

### Game Loop

Das Spiel läuft in einer Schleife (60x pro Sekunde):

```
Update Phase
    ↓
Physics Phase (Schwerkraft, Kollisionen)
    ↓
Render Phase (Zeichnen)
    ↓
Repeat
```

---

## Häufige Aufgaben

### Player bewegen

```kotlin
val rigidbody = player.getComponent<RigidbodyComponent>()!!
rigidbody.setVelocity(200f, 0f)  // Nach rechts
```

### Sound abspielen

```kotlin
val audio = player.getComponent<AudioSourceComponent>()!!
audio.playSound("jump_sfx")
```

### Animation abspielen

```kotlin
val animation = player.getComponent<AnimationComponent>()!!
animation.frames = listOf(
    AnimationComponent.Frame("sprite_1", 0.1f),
    AnimationComponent.Frame("sprite_2", 0.1f),
    AnimationComponent.Frame("sprite_3", 0.1f)
)
animation.play()
```

### Entity zerstören

```kotlin
player.destroy()
```

### Spiel-Variablen speichern

```kotlin
gameEngine.gameState.setInt("score", 100)
gameEngine.gameState.setBoolean("isPaused", true)

val score = gameEngine.gameState.getInt("score")
```

---

## Component-Referenz

### SpriteComponent
Grafik anzeigen:
- `spriteId` - Asset ID
- `tintColor` - Farbton (0xRRGGBB)
- `sortingOrder` - Zeichnungsreihenfolge (höher = oben)
- `flipX / flipY` - Spiegeln

### RigidbodyComponent
Physik & Bewegung:
- `mass` - Gewicht (beeinflusst Beschleunigung)
- `useGravity` - Schwerkraft anwenden?
- `isStatic` - Unbeweglich (Boden, Wände)?
- `velocityX/Y` - Aktuelle Geschwindigkeit
- `setVelocity(x, y)` - Geschwindigkeit setzen
- `applyForce(x, y)` - Kraft ausüben

### BoxColliderComponent & CircleColliderComponent
Kollisionen erkennen:
- `width/height` (BoxCollider) - Größe
- `radius` (CircleCollider) - Radius

### AnimationComponent
Animationen abspielen:
- `frames` - Liste von Frames
- `isLooping` - Wiederholen?
- `play()` - Start
- `stop()` - Stop
- `onAnimationComplete` - Callback

---

## Tipps für Anfänger

### 1. Klein anfangen
Beginne mit einem einfachen Spiel (Flappy Bird, Jump Quest, etc.) statt komplexer Spiele.

### 2. Teste häufig
Nutze den Play-Button im Editor um schnell zu testen. Speicher & reload die szene.

### 3. Organisiere Entities
Gib Entities aussagekräftige Namen ("Player", "Enemy_1", "Ground") damit du weißt was sie tun.

### 4. Nutze die Inspector
Der Inspector zeigt alle Properties. Ändere Werte zur Laufzeit um das Spiel zu "tunen".

### 5. Debugging
```kotlin
println("Player position: ${player.position}")
println("Collision detected!")
```

### 6. Assets organisieren
- `sprites/` - Bilder
- `sounds/` - Audio-Dateien
- `tilemaps/` - Level-Daten

### 7. Performance beachten
Zu viele Entities oder Kollisionen = langsames Spiel. Nutze Static Rigidbodies für unbewegte Objekte!

---

## Nächste Schritte

✅ **Geschafft!** Du hast:
- [x] Ein Projekt erstellt
- [x] Entities und Components verstanden
- [x] Ein funktionierendes Spiel gebaut
- [x] Eine APK exportiert

### Jetzt kannst du:

1. **Flappy Bird erweitern**
   - Score-System hinzufügen
   - Sound Effects einbauen
   - Game Over Bildschirm
   - Schwierigkeitsstufen

2. **Neues Spiel beginnen**
   - Platformer (Jump & Run)
   - Puzzle-Game (Match-3)
   - Tap-to-Jump

3. **Engine erlernen**
   - CLAUDE.md lesen (Architektur)
   - API-Referenz studieren
   - Sample-Projekte untersuchen

---

## Häufig gestellte Fragen

**F: Kann ich Python oder andere Sprachen nutzen?**
A: Nein, aktuell nur Kotlin. Die Engine basiert auf Kotlin/Android.

**F: Wie groß werden die APKs?**
A: ~10-15 MB für ein einfaches Spiel (ohne Assets).

**F: Kann ich mein Spiel auf dem Play Store veröffentlichen?**
A: Ja! Einfach eine signierte APK bauen und hochladen.

**F: Wo speichere ich Spielstände?**
A: Nutze `gameEngine.gameState` zum Speichern während des Spiels. Für permanente Speicherung: Android SharedPreferences.

**F: Wie viele Entities kann ich maximal nutzen?**
A: ~1000 Entities mit Physik sind möglich, je nach Handy. Nutze Object Pooling für viele ähnliche Objekte!

---

## Support & Community

- 📖 **Dokumentation**: README.md, CLAUDE.md, diese Anleitung
- 🐛 **Bugs melden**: GitHub Issues
- 💬 **Fragen**: GitHub Discussions
- 🎮 **Samples**: samples/ Verzeichnis

---

**Viel Spaß beim Game Development! 🚀**
