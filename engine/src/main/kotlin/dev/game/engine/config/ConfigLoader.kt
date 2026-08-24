package dev.game.engine.config

import android.content.Context
import kotlinx.serialization.json.Json
import java.io.File

object ConfigLoader {
    private val json = Json { ignoreUnknownKeys = true }

    fun loadGameConfig(context: Context, fileName: String = "game.json"): GameConfig? {
        return try {
            val file = File(context.filesDir, fileName)
            if (file.exists()) {
                val jsonString = file.readText()
                json.decodeFromString<GameConfig>(jsonString)
            } else {
                null
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun loadGameConfigFromAssets(context: Context, fileName: String = "game.json"): GameConfig? {
        return try {
            val jsonString = context.assets.open(fileName).bufferedReader().readText()
            json.decodeFromString<GameConfig>(jsonString)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun loadSceneConfig(context: Context, fileName: String): SceneConfig? {
        return try {
            val jsonString = context.assets.open(fileName).bufferedReader().readText()
            json.decodeFromString<SceneConfig>(jsonString)
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    fun saveGameConfig(context: Context, config: GameConfig, fileName: String = "game.json") {
        try {
            val file = File(context.filesDir, fileName)
            val jsonString = json.encodeToString(GameConfig.serializer(), config)
            file.writeText(jsonString)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
