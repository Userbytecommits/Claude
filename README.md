# Android Game Engine 🎮

Eine extrem anfängerfreundliche 2D Game Engine für Android Handys, speziell optimiert für einfache Bedienung und visuelle Spielentwicklung ohne komplexe Programmierung.

## Features

✅ **2D Sprite Rendering** - Canvas & OpenGL-basiertes Rendering mit Camera-System  
✅ **Physics & Collision** - Lightweight 2D Physics mit Box & Circle Collider  
✅ **Audio System** - Sound Effects und Background Music  
✅ **Input Handling** - Multi-touch und Keyboard Input  
✅ **Component Architecture** - Modulares Entity-Component System  
✅ **Scene Management** - Einfaches Laden und Verwalten von Szenen  
✅ **Animation System** - Sprite-basierte Frame Animations  
✅ **JSON Config** - Spiele über Konfigurationsdateien definierbar  

## Project Structure

```
android-game-engine/
├── engine/                 # Core Game Engine (Android Library)
├── editor/                 # Visual Game Editor (JavaFX) - TODO
├── runtime-template/       # APK Template für Game Export
├── samples/
│   └── flappy-bird/       # Example: Flappy Bird Clone
└── docs/                  # Documentation
```

## Quick Start

### 1. Minimales Game Setup

```kotlin
val gameEngine = GameEngine(context)
val scene = Scene("MainScene")

// Erstelle einen Player Entity
val player = Entity("Player").apply {
    position = Vector2(540f, 960f)
    
    // Füge Sprite hinzu
    val sprite = addComponent(SpriteComponent())
    sprite.tintColor = 0xFFFFD700.toInt()
    
    // Füge Physics hinzu
    val rigidbody = addComponent(RigidbodyComponent())
    rigidbody.gameEngine = gameEngine
    rigidbody.useGravity = true
    rigidbody.mass = 1f
    
    // Füge Collider hinzu
    val collider = addComponent(BoxColliderComponent(32f, 32f))
    collider.gameEngine = gameEngine
}

scene.addEntity(player)
gameEngine.loadScene(scene)
```

### 2. Input Handling

```kotlin
// Touch Input
if (gameEngine.inputManager.isTouched()) {
    val touchPos = gameEngine.inputManager.getTouchPosition(0)
    // Reagiere auf Touch
}

// Keyboard Input
if (gameEngine.inputManager.isKeyPressed(KeyEvent.KEYCODE_SPACE)) {
    player.getComponent<RigidbodyComponent>()?.addVelocity(0f, -20f)
}
```

### 3. Collision Detection

```kotlin
gameEngine.physicsWorld.onCollision { entity1, entity2 ->
    println("${entity1.name} collided with ${entity2.name}")
}
```

### 4. Animations

```kotlin
val animation = entity.addComponent(AnimationComponent())
animation.frames = mutableListOf(
    AnimationComponent.Frame("sprite_1", 0.1f),
    AnimationComponent.Frame("sprite_2", 0.1f),
    AnimationComponent.Frame("sprite_3", 0.1f)
)
animation.isLooping = true
animation.play()
```

## Core Components

### RigidbodyComponent
Physik und Bewegung für Entities.
- `mass` - Masse (beeinflusst Beschleunigung)
- `useGravity` - Schwerkraft anwenden?
- `isStatic` - Unbeweglich (z.B. Boden)?
- `setVelocity(x, y)` - Geschwindigkeit setzen
- `applyForce(x, y)` - Kraft anwenden

### BoxColliderComponent & CircleColliderComponent
Kollisionserkennung mit verschiedenen Formen.

### SpriteComponent
Visuelles Rendering mit Farben und Sorting-Order.

### AnimationComponent
Frame-basierte Sprite-Animationen.

### AudioSourceComponent
Sound Effects und Musik.

## Camera System

```kotlin
val camera = renderer.camera
camera.zoom = 2f  // 2x Zoom
camera.follow(playerPos, 0.1f)  // Sanfte Kamera-Verfolgung
```

## Physics Configuration

```kotlin
gameEngine.gravity = 15f  // Gravity Stärke

val body = rigidbody.physicsBody
body.gravityScale = 1f  // Individuelle Gravity Skalierung
body.mass = 2f
```

## Architecture

### Entity-Component System
Jedes Objekt im Spiel ist eine **Entity** mit einer Liste von **Components**. Components sind modulare Funktionen, die Entity-Verhalten definieren.

### Game Loop
1. **Update Phase** - Update all Components, Eingabe verarbeiten
2. **Physics Phase** - Kräfte anwenden, Velocities integrieren, Kollisionen lösen
3. **Render Phase** - Alle Entities zeichnen
4. **Cleanup** - Zerstörte Entities entfernen

### Scene Management
Szenen kapseln eine Sammlung von Entities und deren State. Wechsel zwischen Szenen mit `gameEngine.loadScene(scene)`.

## Configuration Format (JSON)

**game.json** - Spielkonfiguration:
```json
{
  "game": {
    "name": "Mein Spiel",
    "version": "1.0.0",
    "packageName": "com.example.mygame",
    "width": 1080,
    "height": 1920
  },
  "scenes": [
    {"id": "scene_main", "name": "Main", "file": "scenes/main.json"}
  ]
}
```

**scenes/main.json** - Szenendefinition:
```json
{
  "entities": [
    {
      "id": "player_1",
      "name": "Player",
      "position": {"x": 540, "y": 960},
      "components": [
        {"type": "SpriteComponent", "properties": {"tintColor": "0xFFFFD700"}},
        {"type": "RigidbodyComponent", "properties": {"mass": 1.0, "useGravity": true}},
        {"type": "BoxColliderComponent", "properties": {"width": 32, "height": 32}}
      ]
    }
  ]
}
```

## Development Roadmap

- ✅ **Phase 1** - Core Engine Foundation (Game Loop, Entity/Component System, Physics)
- ✅ **Phase 2** - Rendering System (Camera, Sprite Rendering, Animation)
- 🔄 **Phase 3** - Audio System (SFX, Music, Volume Control)
- 📋 **Phase 4** - Configuration & Loading (JSON Config, Scene Loading)
- 📋 **Phase 5** - Visual Editor (JavaFX Editor für Anfänger)
- 📋 **Phase 6** - APK Generation (Gradle-basiertes Packaging)
- 📋 **Phase 7** - Sample Games & Documentation (Flappy Bird, Platformer, etc.)

## Performance Tips

- Nutze **Sprite Culling** - Nur sichtbare Entities rendern
- **Sprite Pooling** - Wiederverwendung von häufig erstellten Objekten
- **Spatial Partitioning** - Effizientere Kollisionserkennung bei vielen Objekten
- **Canvas vs OpenGL** - Canvas für Tilemaps/UI, OpenGL für High-Performance Rendering

## License

MIT License - Frei verwendbar für kommerzielle und private Projekte.

## Credits

Entwickelt als vollständig anfängerfreundliche Android Game Engine mit visuellem Editor.