package dev.game.engine.utils

data class Rect(
    var x: Float = 0f,
    var y: Float = 0f,
    var width: Float = 0f,
    var height: Float = 0f
) {
    val left: Float get() = x
    val right: Float get() = x + width
    val top: Float get() = y
    val bottom: Float get() = y + height

    val centerX: Float get() = x + width / 2
    val centerY: Float get() = y + height / 2

    fun contains(point: Vector2): Boolean =
        point.x >= x && point.x < x + width &&
        point.y >= y && point.y < y + height

    fun intersects(other: Rect): Boolean =
        x < other.x + other.width &&
        x + width > other.x &&
        y < other.y + other.height &&
        y + height > other.y

    fun set(x: Float, y: Float, width: Float, height: Float) {
        this.x = x
        this.y = y
        this.width = width
        this.height = height
    }

    fun copy(): Rect = Rect(x, y, width, height)
}
