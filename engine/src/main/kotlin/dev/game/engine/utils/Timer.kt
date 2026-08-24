package dev.game.engine.utils

class Timer(val duration: Float = 1f) {
    var timeRemaining = duration
    var isRunning = false

    var onComplete: (() -> Unit)? = null

    fun start() {
        isRunning = true
        timeRemaining = duration
    }

    fun stop() {
        isRunning = false
    }

    fun reset() {
        timeRemaining = duration
    }

    fun update(deltaTime: Float) {
        if (!isRunning) return

        timeRemaining -= deltaTime
        if (timeRemaining <= 0) {
            timeRemaining = 0f
            isRunning = false
            onComplete?.invoke()
        }
    }

    fun progress(): Float = 1f - (timeRemaining / duration).coerceIn(0f, 1f)

    fun isFinished(): Boolean = timeRemaining <= 0
}
