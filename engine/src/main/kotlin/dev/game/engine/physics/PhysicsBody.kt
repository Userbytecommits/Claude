package dev.game.engine.physics

import dev.game.engine.utils.Vector2

class PhysicsBody {
    var velocity = Vector2(0f, 0f)
    var acceleration = Vector2(0f, 0f)
    var mass = 1f
    var isStatic = false
    var useGravity = true
    var gravityScale = 1f

    var collider: Collider? = null

    fun applyForce(force: Vector2) {
        if (!isStatic) {
            acceleration.x += force.x / mass
            acceleration.y += force.y / mass
        }
    }

    fun setVelocity(x: Float, y: Float) {
        velocity.set(x, y)
    }

    fun addVelocity(x: Float, y: Float) {
        velocity.x += x
        velocity.y += y
    }
}
