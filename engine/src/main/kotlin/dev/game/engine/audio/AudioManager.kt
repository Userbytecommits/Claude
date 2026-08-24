package dev.game.engine.audio

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.SoundPool
import java.io.FileDescriptor

class AudioManager(val context: Context) {
    private val soundPool = SoundPool.Builder()
        .setMaxStreams(16)
        .setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
        )
        .build()

    private val soundIds = mutableMapOf<String, Int>()
    private val musicPlayers = mutableMapOf<String, MediaPlayer>()
    private var masterVolume = 1f

    fun loadSoundEffect(name: String, assetPath: String) {
        try {
            val afd = context.assets.openFd(assetPath)
            val soundId = soundPool.load(afd, 1)
            soundIds[name] = soundId
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun playSound(name: String, volume: Float = 1f, pitch: Float = 1f) {
        val soundId = soundIds[name] ?: return
        soundPool.play(soundId, volume * masterVolume, volume * masterVolume, 0, 0, pitch)
    }

    fun loadMusic(name: String, assetPath: String) {
        try {
            val afd = context.assets.openFd(assetPath)
            val player = MediaPlayer()
            player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            player.prepare()
            musicPlayers[name] = player
            afd.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun playMusic(name: String, looping: Boolean = true, volume: Float = 1f) {
        val player = musicPlayers[name] ?: return
        player.isLooping = looping
        player.setVolume(volume * masterVolume, volume * masterVolume)
        try {
            player.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun pauseMusic(name: String) {
        musicPlayers[name]?.pause()
    }

    fun stopMusic(name: String) {
        musicPlayers[name]?.let {
            it.stop()
            try {
                it.prepare()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun setMasterVolume(volume: Float) {
        masterVolume = volume.coerceIn(0f, 1f)
    }

    fun getMasterVolume(): Float = masterVolume

    fun release() {
        soundPool.release()
        musicPlayers.values.forEach {
            it.stop()
            it.release()
        }
        musicPlayers.clear()
        soundIds.clear()
    }
}
