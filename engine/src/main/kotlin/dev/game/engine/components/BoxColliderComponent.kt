package dev.game.engine.components

import dev.game.engine.core.Component
import dev.game.engine.core.GameEngine
import dev.game.engine.physics.BoxCollider

class BoxColliderComponent(val width: Float = 1f, val height: Float = 1f) : Component() {
    lateinit var gameEngine: GameEngine

    private val collider = BoxCollider(width, height)

    override fun onCreate() {
        super.onCreate()
        val rigidbody = entity.getComponent<RigidbodyComponent>()
        if (rigidbody != null) {
            rigidbody.physicsBody.collider = collider
        }
    }
}
