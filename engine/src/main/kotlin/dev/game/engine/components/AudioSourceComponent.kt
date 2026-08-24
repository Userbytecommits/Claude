package dev.game.engine.components

import dev.game.engine.audio.AudioManager
import dev.game.engine.core.Component

class AudioSourceComponent : Component() {
    lateinit var audioManager: AudioManager
    var currentAudioName: String = ""
    var volume: Float = 1f
    var pitch: Float = 1f

    fun playSound(soundName: String) {
        currentAudioName = soundName
        audioManager.playSound(soundName, volume, pitch)
    }

    fun playMusic(musicName: String, looping: Boolean = true) {
        currentAudioName = musicName
        audioManager.playMusic(musicName, looping, volume)
    }

    fun stop() {
        if (currentAudioName.isNotEmpty()) {
            audioManager.stopMusic(currentAudioName)
            currentAudioName = ""
        }
    }

    fun pause() {
        if (currentAudioName.isNotEmpty()) {
            audioManager.pauseMusic(currentAudioName)
        }
    }
}
