package dev.game.engine.core

import dev.game.engine.utils.Vector2

class InputManager {
    private val touchPoints = mutableMapOf<Int, TouchPoint>()
    private val pressedKeys = mutableSetOf<Int>()

    data class TouchPoint(val pointerId: Int, var x: Float, var y: Float)

    fun updateTouchDown(pointerId: Int, x: Float, y: Float) {
        touchPoints[pointerId] = TouchPoint(pointerId, x, y)
    }

    fun updateTouchMove(pointerId: Int, x: Float, y: Float) {
        touchPoints[pointerId]?.let {
            it.x = x
            it.y = y
        }
    }

    fun updateTouchUp(pointerId: Int) {
        touchPoints.remove(pointerId)
    }

    fun updateKeyDown(keyCode: Int) {
        pressedKeys.add(keyCode)
    }

    fun updateKeyUp(keyCode: Int) {
        pressedKeys.remove(keyCode)
    }

    fun isTouched(): Boolean = touchPoints.isNotEmpty()

    fun getTouchPosition(pointerId: Int = 0): Vector2? {
        return touchPoints[pointerId]?.let { Vector2(it.x, it.y) }
    }

    fun getAllTouches(): List<Vector2> {
        return touchPoints.values.map { Vector2(it.x, it.y) }
    }

    fun isKeyPressed(keyCode: Int): Boolean = keyCode in pressedKeys

    fun clear() {
        touchPoints.clear()
        pressedKeys.clear()
    }
}
