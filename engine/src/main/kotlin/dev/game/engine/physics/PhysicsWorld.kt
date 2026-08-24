package dev.game.engine.physics

import dev.game.engine.core.Entity
import dev.game.engine.utils.Vector2

class PhysicsWorld {
    var gravity = Vector2(0f, 9.8f)
    private val bodies = mutableMapOf<Entity, PhysicsBody>()

    private val collisionCallbacks = mutableListOf<CollisionCallback>()

    fun registerBody(entity: Entity, body: PhysicsBody) {
        bodies[entity] = body
    }

    fun unregisterBody(entity: Entity) {
        bodies.remove(entity)
    }

    fun getBody(entity: Entity): PhysicsBody? = bodies[entity]

    fun step(deltaTime: Float) {
        applyForces(deltaTime)
        integrateVelocities(deltaTime)
        detectAndResolveCollisions()
    }

    private fun applyForces(deltaTime: Float) {
        bodies.forEach { (_, body) ->
            if (!body.isStatic) {
                if (body.useGravity) {
                    body.acceleration.y += gravity.y * body.gravityScale
                }
                body.velocity.x += body.acceleration.x * deltaTime
                body.velocity.y += body.acceleration.y * deltaTime
                body.acceleration.set(0f, 0f)
            }
        }
    }

    private fun integrateVelocities(deltaTime: Float) {
        bodies.forEach { (entity, body) ->
            if (!body.isStatic) {
                entity.position.x += body.velocity.x * deltaTime
                entity.position.y += body.velocity.y * deltaTime
            }
        }
    }

    private fun detectAndResolveCollisions() {
        val bodiesList = bodies.toList()

        for (i in bodiesList.indices) {
            for (j in i + 1 until bodiesList.size) {
                val (entity1, body1) = bodiesList[i]
                val (entity2, body2) = bodiesList[j]

                if (body1.collider == null || body2.collider == null) continue
                if (body1.isStatic && body2.isStatic) continue

                val collider1 = body1.collider!!
                val collider2 = body2.collider!!

                if (collider1.checkCollision(
                        collider2,
                        entity1.position,
                        entity1.scale,
                        entity2.position,
                        entity2.scale
                    )
                ) {
                    notifyCollision(entity1, entity2)
                    resolveCollision(entity1, body1, entity2, body2)
                }
            }
        }
    }

    private fun resolveCollision(
        entity1: Entity,
        body1: PhysicsBody,
        entity2: Entity,
        body2: PhysicsBody
    ) {
        if (body1.isStatic && body2.isStatic) return

        val minSeparation = 0.01f
        val overlap = 0.1f

        val collisionNormal = entity2.position - entity1.position
        val distance = collisionNormal.length()

        if (distance == 0f) return

        collisionNormal.normalize()

        val relativeVelocity = body2.velocity - body1.velocity
        val velocityAlongNormal = relativeVelocity.dot(collisionNormal)

        if (velocityAlongNormal >= 0) return

        if (!body1.isStatic) {
            entity1.position.x -= collisionNormal.x * overlap / 2
            entity1.position.y -= collisionNormal.y * overlap / 2
        }

        if (!body2.isStatic) {
            entity2.position.x += collisionNormal.x * overlap / 2
            entity2.position.y += collisionNormal.y * overlap / 2
        }

        val restitution = 0.2f
        val impulse = -(1f + restitution) * velocityAlongNormal /
            (1f / body1.mass + 1f / body2.mass).coerceAtLeast(0.0001f)

        if (!body1.isStatic) {
            body1.velocity.x -= (impulse * collisionNormal.x) / body1.mass
            body1.velocity.y -= (impulse * collisionNormal.y) / body1.mass
        }

        if (!body2.isStatic) {
            body2.velocity.x += (impulse * collisionNormal.x) / body2.mass
            body2.velocity.y += (impulse * collisionNormal.y) / body2.mass
        }
    }

    fun onCollision(callback: (Entity, Entity) -> Unit) {
        collisionCallbacks.add(CollisionCallback(callback))
    }

    private fun notifyCollision(entity1: Entity, entity2: Entity) {
        collisionCallbacks.forEach { it.invoke(entity1, entity2) }
    }

    private class CollisionCallback(val callback: (Entity, Entity) -> Unit) {
        fun invoke(e1: Entity, e2: Entity) = callback(e1, e2)
    }
}
