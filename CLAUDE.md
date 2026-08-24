# Android Game Engine - CLAUDE.md

## Project Overview

A beginner-friendly 2D game engine for Android that makes game development visual and code-light. Developers can build games through drag-and-drop entity creation and component management in a JavaFX editor, then export directly to APK.

**Status**: Phase 5/8 Complete (Core Engine + Editor Foundation)

## Architecture

### Multi-Module Structure

```
android-game-engine/
├── engine/              # Core game engine library (Android)
├── editor/              # Desktop game editor (JavaFX)
├── runtime-template/    # Template for APK generation
└── samples/             # Example games
    └── flappy-bird/     # Flappy Bird clone starter
```

### Core Design Patterns

**Entity-Component System (ECS)**
- `Entity`: Container with position, rotation, scale
- `Component`: Modular behavior units (SpriteComponent, RigidbodyComponent, etc.)
- `Scene`: Manager for entities in a level

**Game Loop**
1. **Update Phase**: Entities update, input processed
2. **Physics Phase**: Forces applied, velocities integrated, collisions detected
3. **Render Phase**: All entities drawn to canvas
4. **Cleanup**: Destroyed entities removed

## Key Components

### Core Engine (engine/)

**Game Loop & Lifecycle**
- `GameEngine` - Main loop with 60 FPS target
- `Scene` - Level/scene container with entity management
- `Entity` - Object with position, rotation, scale, and components
- `Component` - Abstract base for all entity behavior

**Physics System**
- `PhysicsWorld` - Gravity, force integration, collision detection
- `PhysicsBody` - Per-entity physics (mass, velocity, static/dynamic)
- `BoxCollider`, `CircleCollider` - AABB and circle collision shapes
- Impulse-based collision resolution with restitution

**Graphics**
- `Renderer` - Canvas-based sprite rendering with sorting
- `Camera` - World-to-screen transformation, zoom, following
- `SpriteComponent` - Visual representation
- `AnimationComponent` - Frame-based sprite animations
- `TilemapComponent` - Grid-based tile rendering

**Input**
- `InputManager` - Touch and keyboard event tracking
- Multi-touch support with pointerId tracking

**Audio**
- `AudioManager` - SoundPool (SFX) + MediaPlayer (music)
- Asset-based loading from resources
- `AudioSourceComponent` - Per-entity audio playback

**Configuration**
- `GameConfig`, `SceneConfig` - JSON-serializable game definitions
- `ConfigLoader` - Load game configs from assets
- `SceneBuilder` - Build Scene instances from JSON config

**Events & State**
- `EventSystem` - Pub/Sub event pattern
- `GameState` - Type-safe key-value game variable storage

### Visual Editor (editor/)

**Desktop Application**
- `Editor` - JavaFX Application entry point
- `EditorWindow` - Main UI with menu bar and panels

**UI Components**
- `GameCanvasPanel` - Game preview and entity editing canvas
- `InspectorPanel` - Entity properties and component listing
- Scene tree hierarchy (left panel)

**Project Management**
- `GameProject` - Project directory structure and config
- File I/O (TODO: full persistence)
- Scene creation helpers

### Runtime (runtime-template/)

- `GameSurfaceView` - Android SurfaceView for rendering
- `MainActivity` - Activity entry point, engine initialization
- Async render thread at 60 FPS

## Development Status

### ✅ Completed Phases

**Phase 1: Core Engine Foundation**
- [x] Game loop with Choreographer
- [x] Entity/Component architecture
- [x] Scene management
- [x] Input manager
- [x] Lightweight physics with collision detection

**Phase 2: Rendering System**
- [x] Canvas-based sprite rendering
- [x] Camera system with zoom & following
- [x] Sprite sorting by order
- [x] Rotation & scaling support

**Phase 3: Audio System**
- [x] SoundPool for SFX
- [x] MediaPlayer for music
- [x] Volume control
- [x] Asset-based loading

**Phase 4: Configuration & Loading**
- [x] JSON-based game config format
- [x] Scene builder from JSON
- [x] Component deserialization
- [x] Event system
- [x] Game state manager

**Phase 5: Visual Editor Foundation**
- [x] JavaFX editor window
- [x] Menu bar structure
- [x] Game canvas panel
- [x] Inspector panel
- [x] Scene hierarchy view
- [x] Project creation

### 🔄 In Progress / TODO

**Phase 6: Editor Advanced Features**
- [ ] Full entity editing UI
- [ ] Drag & drop on canvas
- [ ] Component property editing
- [ ] Undo/redo system
- [ ] Project save/load
- [ ] Asset browser

**Phase 7: APK Generation**
- [ ] Gradle-based APK builder
- [ ] Game config injection
- [ ] Android manifest generation
- [ ] Asset bundling

**Phase 8: Sample Games & Docs**
- [ ] Complete Flappy Bird example
- [ ] Platformer example
- [ ] Tutorial videos
- [ ] API documentation

## Quick Start for Development

### Building the Engine

```bash
./gradlew :engine:build
```

### Running Editor (Desktop)

```bash
./gradlew :editor:run
```

### Building Flappy Bird Sample

```bash
./gradlew :samples:flappy-bird:build
```

### Creating a New Game

```kotlin
// Create engine and scene
val engine = GameEngine(context)
val scene = Scene("MainGame")

// Create player entity
val player = Entity("Player").apply {
    position = Vector2(540f, 960f)
    addComponent(SpriteComponent())
    addComponent(RigidbodyComponent()).apply {
        gameEngine = engine
        useGravity = true
    }
    addComponent(BoxColliderComponent(32f, 32f))
}

scene.addEntity(player)
engine.loadScene(scene)
```

## Key Files to Know

### Engine Core
- `engine/src/main/kotlin/dev/game/engine/core/GameEngine.kt` - Main game loop
- `engine/src/main/kotlin/dev/game/engine/core/Entity.kt` - Entity implementation
- `engine/src/main/kotlin/dev/game/engine/core/Component.kt` - Component base

### Physics
- `engine/src/main/kotlin/dev/game/engine/physics/PhysicsWorld.kt` - Simulation
- `engine/src/main/kotlin/dev/game/engine/physics/Collider.kt` - Collision shapes

### Graphics
- `engine/src/main/kotlin/dev/game/engine/graphics/Renderer.kt` - Rendering pipeline
- `engine/src/main/kotlin/dev/game/engine/graphics/Camera.kt` - Camera system

### Configuration
- `engine/src/main/kotlin/dev/game/engine/config/GameConfig.kt` - Config data
- `engine/src/main/kotlin/dev/game/engine/config/SceneBuilder.kt` - Scene builder

### Editor
- `editor/src/main/kotlin/dev/game/editor/ui/EditorWindow.kt` - Main editor UI
- `editor/src/main/kotlin/dev/game/editor/project/GameProject.kt` - Project model

### Runtime
- `runtime-template/src/main/kotlin/dev/game/runtime/MainActivity.kt` - App entry
- `runtime-template/src/main/kotlin/dev/game/runtime/GameSurfaceView.kt` - Rendering

## Configuration Format

### game.json

```json
{
  "game": {
    "name": "My Game",
    "version": "1.0.0",
    "packageName": "com.example.mygame",
    "width": 1080,
    "height": 1920,
    "orientation": "portrait"
  },
  "scenes": [
    {"id": "scene_main", "name": "Main", "file": "scenes/main.json"}
  ],
  "assets": {
    "sprites": [
      {"id": "sprite_bird", "file": "sprites/bird.png", "width": 32, "height": 32}
    ],
    "sounds": [
      {"id": "sfx_jump", "file": "audio/jump.wav", "type": "sfx"}
    ]
  }
}
```

### scenes/main.json

```json
{
  "entities": [
    {
      "id": "player_1",
      "name": "Player",
      "position": {"x": 540, "y": 960},
      "components": [
        {"type": "SpriteComponent", "properties": {"spriteId": "sprite_bird"}},
        {"type": "RigidbodyComponent", "properties": {"mass": 1.0, "useGravity": true}},
        {"type": "BoxColliderComponent", "properties": {"width": 32, "height": 32}}
      ]
    }
  ]
}
```

## Extension Points

### Adding Custom Components

```kotlin
class CustomComponent : Component() {
    override fun update(deltaTime: Float) {
        // Custom logic
    }
}
```

### Event Handling

```kotlin
gameEngine.eventSystem.subscribe<EntityCollisionEvent>("collision") { event ->
    println("${event.entity1.name} hit ${event.entity2.name}")
}
```

### Custom Configuration Loading

Extend `ConfigLoader` to support additional config sources (files, network, etc.)

## Performance Considerations

- **Rendering**: Sprite culling (only visible sprites render)
- **Physics**: Spatial partitioning for collision queries
- **Memory**: Entity pooling for frequently created/destroyed objects
- **CPU**: Choreographer syncs with screen refresh rate (60 FPS)

## Dependencies

### Engine
- Kotlin stdlib
- AndroidX libraries
- Kotlinx Serialization (JSON)

### Editor
- JavaFX 21
- Kotlin stdlib
- Kotlinx Serialization

### Runtime
- Android SDK 21+
- Kotlin stdlib
- AndroidX libraries

## Next Steps

1. **Phase 6 (Editor)**: Full entity editing with drag-and-drop
2. **Phase 7 (APK)**: Complete APK generation pipeline
3. **Phase 8 (Samples)**: Finish Flappy Bird, add Platformer/Puzzle examples
4. **Polish**: Optimization, error handling, user feedback

## Contributing Guidelines

- Keep components focused (single responsibility)
- Use meaningful variable names
- Add brief comments for non-obvious logic
- Test components in isolation
- Follow Kotlin naming conventions

## License

MIT - Free for commercial and personal use.
