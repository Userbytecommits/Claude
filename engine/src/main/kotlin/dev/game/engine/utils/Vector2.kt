package dev.game.engine.utils

import kotlin.math.sqrt

data class Vector2(var x: Float = 0f, var y: Float = 0f) {
    fun length(): Float = sqrt(x * x + y * y)

    fun distance(other: Vector2): Float {
        val dx = x - other.x
        val dy = y - other.y
        return sqrt(dx * dx + dy * dy)
    }

    fun normalize(): Vector2 {
        val len = length()
        if (len > 0) {
            x /= len
            y /= len
        }
        return this
    }

    fun dot(other: Vector2): Float = x * other.x + y * other.y

    operator fun plus(other: Vector2): Vector2 = Vector2(x + other.x, y + other.y)
    operator fun minus(other: Vector2): Vector2 = Vector2(x - other.x, y - other.y)
    operator fun times(scalar: Float): Vector2 = Vector2(x * scalar, y * scalar)
    operator fun div(scalar: Float): Vector2 = Vector2(x / scalar, y / scalar)

    fun set(x: Float, y: Float) {
        this.x = x
        this.y = y
    }

    fun copy(): Vector2 = Vector2(x, y)
}
