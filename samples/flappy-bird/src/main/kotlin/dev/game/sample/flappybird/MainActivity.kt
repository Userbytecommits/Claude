package dev.game.sample.flappybird

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import dev.game.engine.components.BoxColliderComponent
import dev.game.engine.components.RigidbodyComponent
import dev.game.engine.core.Entity
import dev.game.engine.core.GameEngine
import dev.game.engine.core.Scene
import dev.game.engine.graphics.GameSurfaceView
import dev.game.engine.graphics.SpriteComponent
import dev.game.engine.utils.Vector2

class MainActivity : AppCompatActivity() {
    private lateinit var gameEngine: GameEngine
    private lateinit var gameView: GameSurfaceView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        gameView = GameSurfaceView(this)
        setContentView(gameView)

        gameEngine = GameEngine(this)
        gameView.setGameEngine(gameEngine)

        initializeFlappyBirdGame()
    }

    private fun initializeFlappyBirdGame() {
        val scene = Scene("FlappyBirdGame")

        val player = Entity("Player").apply {
            position = Vector2(540f, 960f)

            val sprite = addComponent(SpriteComponent())
            sprite.tintColor = 0xFFFFD700.toInt()
            sprite.sortingOrder = 10

            val rigidbody = addComponent(RigidbodyComponent())
            rigidbody.gameEngine = gameEngine
            rigidbody.mass = 1f
            rigidbody.useGravity = true

            val collider = addComponent(BoxColliderComponent(32f, 32f))
            collider.gameEngine = gameEngine
        }

        val ground = Entity("Ground").apply {
            position = Vector2(540f, 1800f)

            val sprite = addComponent(SpriteComponent())
            sprite.tintColor = 0xFF8B4513.toInt()
            sprite.sortingOrder = 5

            val rigidbody = addComponent(RigidbodyComponent())
            rigidbody.gameEngine = gameEngine
            rigidbody.isStatic = true

            val collider = addComponent(BoxColliderComponent(1080f, 60f))
            collider.gameEngine = gameEngine
        }

        scene.addEntity(player)
        scene.addEntity(ground)

        gameEngine.loadScene(scene)

        gameEngine.physicsWorld.onCollision { entity1, entity2 ->
            if (entity1.name == "Player" && entity2.name == "Ground") {
                println("Player hit ground!")
            } else if (entity1.name == "Ground" && entity2.name == "Player") {
                println("Player hit ground!")
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        gameEngine.destroy()
    }

    override fun onBackPressed() {
        super.onBackPressed()
        finish()
    }
}
