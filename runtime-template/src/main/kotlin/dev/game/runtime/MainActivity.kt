package dev.game.runtime

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import dev.game.engine.core.GameEngine
import dev.game.engine.core.Scene
import dev.game.engine.config.ConfigLoader

class MainActivity : AppCompatActivity() {
    private lateinit var gameEngine: GameEngine
    private lateinit var gameView: GameSurfaceView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        gameView = GameSurfaceView(this)
        setContentView(gameView)

        gameEngine = GameEngine(this)
        gameView.setGameEngine(gameEngine)

        initializeGame()
    }

    private fun initializeGame() {
        val config = ConfigLoader.loadGameConfigFromAssets(this, "game.json")

        if (config != null) {
            // Load first scene from config
            if (config.scenes.isNotEmpty()) {
                val sceneInfo = config.scenes[0]
                val sceneConfig = ConfigLoader.loadSceneConfig(this, sceneInfo.file)

                if (sceneConfig != null) {
                    val scene = Scene(sceneInfo.name)
                    // TODO: Load entities from scene config
                    gameEngine.loadScene(scene)
                } else {
                    createDefaultScene()
                }
            } else {
                createDefaultScene()
            }
        } else {
            createDefaultScene()
        }
    }

    private fun createDefaultScene() {
        val scene = Scene("DefaultScene")
        gameEngine.loadScene(scene)
    }

    override fun onDestroy() {
        super.onDestroy()
        gameEngine.destroy()
    }
}
