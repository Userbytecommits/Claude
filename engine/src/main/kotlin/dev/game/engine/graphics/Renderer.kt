package dev.game.engine.graphics

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import dev.game.engine.core.Entity
import dev.game.engine.core.Scene
import kotlin.math.cos
import kotlin.math.sin

class Renderer {
    val camera = Camera()

    private data class SpriteRenderData(
        val entity: Entity,
        val sprite: SpriteComponent,
        val x: Float,
        val y: Float,
        val sortingOrder: Int
    )

    private val spriteQueue = mutableListOf<SpriteRenderData>()

    fun beginFrame(canvas: Canvas) {
        canvas.drawColor(Color.BLACK)
        spriteQueue.clear()
    }

    fun queueSprite(entity: Entity, sprite: SpriteComponent) {
        val screenPos = camera.worldToScreen(entity.position)
        spriteQueue.add(SpriteRenderData(entity, sprite, screenPos.x, screenPos.y, sprite.sortingOrder))
    }

    fun endFrame(canvas: Canvas) {
        spriteQueue.sortBy { it.sortingOrder }

        spriteQueue.forEach { data ->
            renderSprite(canvas, data)
        }
    }

    private fun renderSprite(canvas: Canvas, data: SpriteRenderData) {
        val paint = Paint().apply {
            color = data.sprite.tintColor
            isAntiAlias = true
        }

        val radius = 32f * data.entity.scale.x * camera.zoom

        // Save canvas state
        canvas.save()

        // Apply rotation if needed
        if (data.entity.rotation != 0f) {
            canvas.rotate(data.entity.rotation, data.x, data.y)
        }

        // Draw circle (placeholder for sprite)
        canvas.drawCircle(data.x, data.y, radius, paint)

        // Draw outline to make it visible
        val outlinePaint = Paint().apply {
            color = Color.WHITE
            style = Paint.Style.STROKE
            strokeWidth = 2f
        }
        canvas.drawCircle(data.x, data.y, radius, outlinePaint)

        // Restore canvas state
        canvas.restore()
    }

    fun renderRect(canvas: Canvas, x: Float, y: Float, width: Float, height: Float, color: Int) {
        val paint = Paint().apply {
            this.color = color
        }

        val screenX = camera.worldToScreen(dev.game.engine.utils.Vector2(x, y)).x
        val screenY = camera.worldToScreen(dev.game.engine.utils.Vector2(x, y)).y

        val scaledWidth = width * camera.zoom
        val scaledHeight = height * camera.zoom

        canvas.drawRect(screenX, screenY, screenX + scaledWidth, screenY + scaledHeight, paint)
    }

    fun renderLine(
        canvas: Canvas,
        x1: Float,
        y1: Float,
        x2: Float,
        y2: Float,
        color: Int,
        strokeWidth: Float = 2f
    ) {
        val paint = Paint().apply {
            this.color = color
            this.strokeWidth = strokeWidth
            isAntiAlias = true
        }

        val startPos = camera.worldToScreen(dev.game.engine.utils.Vector2(x1, y1))
        val endPos = camera.worldToScreen(dev.game.engine.utils.Vector2(x2, y2))

        canvas.drawLine(startPos.x, startPos.y, endPos.x, endPos.y, paint)
    }
}
