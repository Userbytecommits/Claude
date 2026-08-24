package dev.game.engine.graphics

import dev.game.engine.core.Component

class AnimationComponent : Component() {
    data class Frame(val spriteId: String, val duration: Float)

    var frames = mutableListOf<Frame>()
    var isPlaying = false
    var isLooping = true
    var currentFrameIndex = 0
    var timeInFrame = 0f

    var onAnimationComplete: (() -> Unit)? = null

    fun play() {
        isPlaying = true
        currentFrameIndex = 0
        timeInFrame = 0f
    }

    fun stop() {
        isPlaying = false
        currentFrameIndex = 0
        timeInFrame = 0f
    }

    fun pause() {
        isPlaying = false
    }

    override fun update(deltaTime: Float) {
        if (!isPlaying || frames.isEmpty()) return

        timeInFrame += deltaTime
        val currentFrame = frames[currentFrameIndex]

        if (timeInFrame >= currentFrame.duration) {
            timeInFrame -= currentFrame.duration

            currentFrameIndex++
            if (currentFrameIndex >= frames.size) {
                currentFrameIndex = 0
                if (!isLooping) {
                    isPlaying = false
                    onAnimationComplete?.invoke()
                }
            }
        }

        val spriteComponent = entity.getComponent<SpriteComponent>()
        if (spriteComponent != null) {
            spriteComponent.spriteId = currentFrame.spriteId
        }
    }
}
