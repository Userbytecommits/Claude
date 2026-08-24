package dev.game.engine.config

import kotlinx.serialization.Serializable

@Serializable
data class GameConfig(
    val game: GameInfo,
    val scenes: List<SceneInfo> = emptyList(),
    val assets: AssetConfig = AssetConfig(),
    val input: InputConfig = InputConfig()
)

@Serializable
data class GameInfo(
    val name: String,
    val version: String = "1.0.0",
    val packageName: String,
    val targetSDK: Int = 34,
    val width: Int = 1080,
    val height: Int = 1920,
    val orientation: String = "portrait"
)

@Serializable
data class SceneInfo(
    val id: String,
    val name: String,
    val file: String
)

@Serializable
data class AssetConfig(
    val sprites: List<SpriteAsset> = emptyList(),
    val sounds: List<SoundAsset> = emptyList(),
    val tilemaps: List<TilemapAsset> = emptyList()
)

@Serializable
data class SpriteAsset(
    val id: String,
    val file: String,
    val width: Int = 64,
    val height: Int = 64
)

@Serializable
data class SoundAsset(
    val id: String,
    val file: String,
    val type: String = "sfx" // "sfx" or "music"
)

@Serializable
data class TilemapAsset(
    val id: String,
    val file: String,
    val tileWidth: Int = 32,
    val tileHeight: Int = 32
)

@Serializable
data class InputConfig(
    val touchEnabled: Boolean = true,
    val keyboardEnabled: Boolean = true,
    val keyMapping: Map<String, String> = emptyMap()
)

@Serializable
data class SceneConfig(
    val entities: List<EntityConfig> = emptyList()
)

@Serializable
data class EntityConfig(
    val id: String,
    val name: String,
    val position: PositionConfig = PositionConfig(),
    val rotation: Float = 0f,
    val scale: ScaleConfig = ScaleConfig(),
    val components: List<ComponentConfig> = emptyList()
)

@Serializable
data class PositionConfig(val x: Float = 0f, val y: Float = 0f)

@Serializable
data class ScaleConfig(val x: Float = 1f, val y: Float = 1f)

@Serializable
data class ComponentConfig(
    val type: String,
    val properties: Map<String, Any?> = emptyMap()
)
