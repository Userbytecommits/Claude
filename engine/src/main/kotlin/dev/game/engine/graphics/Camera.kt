package dev.game.engine.graphics

import dev.game.engine.utils.Vector2

class Camera {
    var position = Vector2(0f, 0f)
    var zoom = 1f
    var width = 1080f
    var height = 1920f

    fun setViewport(width: Float, height: Float) {
        this.width = width
        this.height = height
    }

    fun worldToScreen(worldPos: Vector2): Vector2 {
        val screenX = ((worldPos.x - position.x) * zoom) + width / 2
        val screenY = ((worldPos.y - position.y) * zoom) + height / 2
        return Vector2(screenX, screenY)
    }

    fun screenToWorld(screenPos: Vector2): Vector2 {
        val worldX = ((screenPos.x - width / 2) / zoom) + position.x
        val worldY = ((screenPos.y - height / 2) / zoom) + position.y
        return Vector2(worldX, worldY)
    }

    fun follow(targetPos: Vector2, smoothSpeed: Float = 0.1f) {
        position.x += (targetPos.x - position.x) * smoothSpeed
        position.y += (targetPos.y - position.y) * smoothSpeed
    }
}
