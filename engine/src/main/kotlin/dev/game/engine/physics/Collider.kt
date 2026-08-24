package dev.game.engine.physics

import dev.game.engine.utils.Rect
import dev.game.engine.utils.Vector2

sealed class Collider {
    abstract fun getAABB(position: Vector2, scale: Vector2): Rect

    abstract fun checkCollision(other: Collider, pos1: Vector2, scale1: Vector2, pos2: Vector2, scale2: Vector2): Boolean
}

class BoxCollider(val width: Float, val height: Float) : Collider() {
    override fun getAABB(position: Vector2, scale: Vector2): Rect {
        val scaledWidth = width * scale.x
        val scaledHeight = height * scale.y
        return Rect(
            position.x - scaledWidth / 2,
            position.y - scaledHeight / 2,
            scaledWidth,
            scaledHeight
        )
    }

    override fun checkCollision(
        other: Collider,
        pos1: Vector2,
        scale1: Vector2,
        pos2: Vector2,
        scale2: Vector2
    ): Boolean {
        val aabb1 = getAABB(pos1, scale1)
        val aabb2 = other.getAABB(pos2, scale2)
        return aabb1.intersects(aabb2)
    }
}

class CircleCollider(val radius: Float) : Collider() {
    override fun getAABB(position: Vector2, scale: Vector2): Rect {
        val scaledRadius = radius * scale.x
        return Rect(
            position.x - scaledRadius,
            position.y - scaledRadius,
            scaledRadius * 2,
            scaledRadius * 2
        )
    }

    override fun checkCollision(
        other: Collider,
        pos1: Vector2,
        scale1: Vector2,
        pos2: Vector2,
        scale2: Vector2
    ): Boolean {
        return when (other) {
            is CircleCollider -> {
                val r1 = radius * scale1.x
                val r2 = other.radius * scale2.x
                val distance = pos1.distance(pos2)
                distance < (r1 + r2)
            }
            is BoxCollider -> {
                val r = radius * scale1.x
                val box = other.getAABB(pos2, scale2)
                circleBoxCollision(pos1, r, box)
            }
        }
    }

    private fun circleBoxCollision(circlePos: Vector2, radius: Float, box: Rect): Boolean {
        val closestX = circlePos.x.coerceIn(box.left, box.right)
        val closestY = circlePos.y.coerceIn(box.top, box.bottom)

        val distanceX = circlePos.x - closestX
        val distanceY = circlePos.y - closestY

        return (distanceX * distanceX + distanceY * distanceY) < (radius * radius)
    }
}
