package dev.game.engine.components

import dev.game.engine.core.Component
import dev.game.engine.core.GameEngine
import dev.game.engine.physics.PhysicsBody

class RigidbodyComponent : Component() {
    lateinit var gameEngine: GameEngine
    val physicsBody = PhysicsBody()

    var mass: Float
        get() = physicsBody.mass
        set(value) {
            physicsBody.mass = value
        }

    var useGravity: Boolean
        get() = physicsBody.useGravity
        set(value) {
            physicsBody.useGravity = value
        }

    var isStatic: Boolean
        get() = physicsBody.isStatic
        set(value) {
            physicsBody.isStatic = value
        }

    var gravityScale: Float
        get() = physicsBody.gravityScale
        set(value) {
            physicsBody.gravityScale = value
        }

    var velocityX: Float
        get() = physicsBody.velocity.x
        set(value) {
            physicsBody.velocity.x = value
        }

    var velocityY: Float
        get() = physicsBody.velocity.y
        set(value) {
            physicsBody.velocity.y = value
        }

    override fun onCreate() {
        super.onCreate()
        gameEngine.physicsWorld.registerBody(entity, physicsBody)
    }

    override fun onDestroy() {
        super.onDestroy()
        gameEngine.physicsWorld.unregisterBody(entity)
    }

    fun applyForce(x: Float, y: Float) {
        physicsBody.applyForce(dev.game.engine.utils.Vector2(x, y))
    }

    fun setVelocity(x: Float, y: Float) {
        physicsBody.setVelocity(x, y)
    }

    fun addVelocity(x: Float, y: Float) {
        physicsBody.addVelocity(x, y)
    }
}
