package dev.game.engine.components

import dev.game.engine.core.Component
import dev.game.engine.physics.CircleCollider

class CircleColliderComponent(val radius: Float = 0.5f) : Component() {
    private val collider = CircleCollider(radius)

    override fun onCreate() {
        super.onCreate()
        val rigidbody = entity.getComponent<RigidbodyComponent>()
        if (rigidbody != null) {
            rigidbody.physicsBody.collider = collider
        }
    }
}
