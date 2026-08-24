package dev.game.engine.core

import android.content.Context
import dev.game.engine.physics.PhysicsWorld

class GameEngine(val context: Context) {
    private var currentScene: Scene? = null
    private var isRunning = false
    private var targetFPS = 60
    private val frameTimeMs = 1000L / targetFPS

    val inputManager = InputManager()
    val physicsWorld = PhysicsWorld()
    val eventSystem = EventSystem()
    val gameState = GameState()

    private var lastFrameTime = System.currentTimeMillis()

    var gravity: Float
        get() = physicsWorld.gravity.y
        set(value) {
            physicsWorld.gravity.y = value
        }

    fun loadScene(scene: Scene) {
        currentScene?.clear()
        currentScene = scene
        eventSystem.publish("scene_loaded", SceneLoadedEvent(scene))
    }

    fun start() {
        isRunning = true
        lastFrameTime = System.currentTimeMillis()
    }

    fun stop() {
        isRunning = false
    }

    fun update() {
        if (!isRunning || currentScene == null) return

        val currentTime = System.currentTimeMillis()
        val deltaTime = ((currentTime - lastFrameTime) / 1000f).coerceAtMost(0.033f)
        lastFrameTime = currentTime

        val scene = currentScene ?: return

        inputManager.clear()

        scene.update(deltaTime)

        physicsWorld.step(deltaTime)

        scene.lateUpdate(deltaTime)

        scene.cleanup()
    }

    fun render() {
        // Rendering will be handled by a separate Renderer component
    }

    fun getCurrentScene(): Scene? = currentScene

    fun destroy() {
        stop()
        currentScene?.clear()
        currentScene = null
        eventSystem.clear()
        gameState.clear()
    }
}
