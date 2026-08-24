package dev.game.engine.config

import android.content.Context
import dev.game.engine.components.BoxColliderComponent
import dev.game.engine.components.CircleColliderComponent
import dev.game.engine.components.RigidbodyComponent
import dev.game.engine.core.Entity
import dev.game.engine.core.GameEngine
import dev.game.engine.core.Scene
import dev.game.engine.graphics.AnimationComponent
import dev.game.engine.graphics.SpriteComponent
import dev.game.engine.utils.Vector2

object SceneBuilder {
    fun buildSceneFromConfig(config: SceneConfig, gameEngine: GameEngine): Scene {
        val scene = Scene()

        config.entities.forEach { entityConfig ->
            val entity = Entity(entityConfig.name).apply {
                position = Vector2(entityConfig.position.x, entityConfig.position.y)
                rotation = entityConfig.rotation
                scale = Vector2(entityConfig.scale.x, entityConfig.scale.y)
            }

            entityConfig.components.forEach { componentConfig ->
                addComponentToEntity(entity, componentConfig, gameEngine)
            }

            scene.addEntity(entity)
        }

        return scene
    }

    private fun addComponentToEntity(
        entity: Entity,
        componentConfig: ComponentConfig,
        gameEngine: GameEngine
    ) {
        when (componentConfig.type) {
            "SpriteComponent" -> {
                val sprite = SpriteComponent()
                componentConfig.properties["spriteId"]?.let {
                    sprite.spriteId = it.toString()
                }
                componentConfig.properties["tintColor"]?.let {
                    sprite.tintColor = parseColor(it.toString())
                }
                componentConfig.properties["sortingOrder"]?.let {
                    sprite.sortingOrder = it.toString().toIntOrNull() ?: 0
                }
                entity.addComponent(sprite)
            }

            "RigidbodyComponent" -> {
                val rigidbody = RigidbodyComponent()
                rigidbody.gameEngine = gameEngine

                componentConfig.properties["mass"]?.let {
                    rigidbody.mass = it.toString().toFloatOrNull() ?: 1f
                }
                componentConfig.properties["useGravity"]?.let {
                    rigidbody.useGravity = it.toString().toBoolean()
                }
                componentConfig.properties["isStatic"]?.let {
                    rigidbody.isStatic = it.toString().toBoolean()
                }
                componentConfig.properties["gravityScale"]?.let {
                    rigidbody.gravityScale = it.toString().toFloatOrNull() ?: 1f
                }
                componentConfig.properties["velocityX"]?.let {
                    rigidbody.velocityX = it.toString().toFloatOrNull() ?: 0f
                }
                componentConfig.properties["velocityY"]?.let {
                    rigidbody.velocityY = it.toString().toFloatOrNull() ?: 0f
                }

                entity.addComponent(rigidbody)
            }

            "BoxColliderComponent" -> {
                val width = componentConfig.properties["width"]?.toString()?.toFloatOrNull() ?: 1f
                val height = componentConfig.properties["height"]?.toString()?.toFloatOrNull() ?: 1f
                val collider = BoxColliderComponent(width, height)
                collider.gameEngine = gameEngine
                entity.addComponent(collider)
            }

            "CircleColliderComponent" -> {
                val radius = componentConfig.properties["radius"]?.toString()?.toFloatOrNull() ?: 0.5f
                val collider = CircleColliderComponent(radius)
                entity.addComponent(collider)
            }

            "AnimationComponent" -> {
                val animation = AnimationComponent()
                @Suppress("UNCHECKED_CAST")
                val frames = componentConfig.properties["frames"] as? List<Map<String, Any>>
                if (frames != null) {
                    animation.frames = frames.map { frameMap ->
                        AnimationComponent.Frame(
                            spriteId = frameMap["spriteId"]?.toString() ?: "",
                            duration = frameMap["duration"]?.toString()?.toFloatOrNull() ?: 0.1f
                        )
                    }.toMutableList()
                }
                componentConfig.properties["isLooping"]?.let {
                    animation.isLooping = it.toString().toBoolean()
                }
                entity.addComponent(animation)
            }
        }
    }

    private fun parseColor(colorString: String): Int {
        return try {
            if (colorString.startsWith("0x")) {
                colorString.substring(2).toLong(16).toInt()
            } else {
                colorString.toLong(16).toInt()
            }
        } catch (e: Exception) {
            0xFFFFFFFF.toInt()
        }
    }
}
