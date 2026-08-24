package dev.game.editor.project

import dev.game.engine.config.GameConfig
import dev.game.engine.config.GameInfo
import dev.game.engine.config.SceneInfo
import dev.game.engine.config.AssetConfig
import dev.game.engine.config.InputConfig
import dev.game.engine.config.SceneConfig
import java.io.File

class GameProject(
    val name: String,
    val packageName: String,
    val projectDir: File
) {
    var gameConfig = GameConfig(
        game = GameInfo(
            name = name,
            packageName = packageName,
            version = "1.0.0"
        ),
        scenes = emptyList(),
        assets = AssetConfig(),
        input = InputConfig(touchEnabled = true, keyboardEnabled = true)
    )

    val assetsDir = File(projectDir, "assets")
    val scenesDir = File(projectDir, "scenes")
    val spritesDir = File(assetsDir, "sprites")
    val soundsDir = File(assetsDir, "sounds")
    val tilemapsDir = File(assetsDir, "tilemaps")

    fun initializeDirectories() {
        projectDir.mkdirs()
        assetsDir.mkdirs()
        scenesDir.mkdirs()
        spritesDir.mkdirs()
        soundsDir.mkdirs()
        tilemapsDir.mkdirs()
    }

    fun createScene(sceneName: String): File {
        val sceneFile = File(scenesDir, "${sceneName.lowercase()}.json")
        val emptyScene = SceneConfig(entities = emptyList())

        // TODO: Write JSON to file
        sceneFile.writeText("{\"entities\": []}")

        return sceneFile
    }

    fun getSceneFile(sceneName: String): File {
        return File(scenesDir, "${sceneName.lowercase()}.json")
    }

    fun save() {
        val gameConfigFile = File(projectDir, "game.json")
        // TODO: Serialize gameConfig to JSON
        gameConfigFile.writeText("{}")
    }

    fun load() {
        val gameConfigFile = File(projectDir, "game.json")
        if (gameConfigFile.exists()) {
            // TODO: Deserialize gameConfig from JSON
        }
    }
}
