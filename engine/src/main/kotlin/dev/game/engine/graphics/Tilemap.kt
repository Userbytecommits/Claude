package dev.game.engine.graphics

import dev.game.engine.core.Component
import dev.game.engine.utils.Rect
import dev.game.engine.utils.Vector2

class TilemapComponent : Component() {
    var tileWidth = 32
    var tileHeight = 32
    var mapWidth = 10
    var mapHeight = 10

    var tiles = mutableMapOf<String, Int>()
    private val tileMap = Array(mapHeight) { IntArray(mapWidth) }

    var tintColor: Int = 0xFFFFFFFF.toInt()
    var sortingOrder: Int = 0

    init {
        for (y in 0 until mapHeight) {
            for (x in 0 until mapWidth) {
                tileMap[y][x] = -1
            }
        }
    }

    fun setTile(x: Int, y: Int, tileId: Int) {
        if (x in 0 until mapWidth && y in 0 until mapHeight) {
            tileMap[y][x] = tileId
        }
    }

    fun getTile(x: Int, y: Int): Int {
        if (x in 0 until mapWidth && y in 0 until mapHeight) {
            return tileMap[y][x]
        }
        return -1
    }

    fun getTilesInRect(rect: Rect): List<Pair<Int, Int>> {
        val tiles = mutableListOf<Pair<Int, Int>>()

        val minX = (rect.x / tileWidth).toInt().coerceIn(0, mapWidth - 1)
        val maxX = ((rect.x + rect.width) / tileWidth).toInt().coerceIn(0, mapWidth - 1)
        val minY = (rect.y / tileHeight).toInt().coerceIn(0, mapHeight - 1)
        val maxY = ((rect.y + rect.height) / tileHeight).toInt().coerceIn(0, mapHeight - 1)

        for (y in minY..maxY) {
            for (x in minX..maxX) {
                if (getTile(x, y) >= 0) {
                    tiles.add(Pair(x, y))
                }
            }
        }

        return tiles
    }

    fun getTileBounds(tileX: Int, tileY: Int): Rect {
        return Rect(
            x = (tileX * tileWidth).toFloat(),
            y = (tileY * tileHeight).toFloat(),
            width = tileWidth.toFloat(),
            height = tileHeight.toFloat()
        )
    }

    fun getWorldPosition(tileX: Int, tileY: Int): Vector2 {
        return Vector2(
            tileX * tileWidth + entity.position.x,
            tileY * tileHeight + entity.position.y
        )
    }

    fun getTileAtWorldPosition(worldX: Float, worldY: Float): Pair<Int, Int>? {
        val relX = (worldX - entity.position.x).toInt()
        val relY = (worldY - entity.position.y).toInt()

        val tileX = relX / tileWidth
        val tileY = relY / tileHeight

        if (tileX in 0 until mapWidth && tileY in 0 until mapHeight) {
            return Pair(tileX, tileY)
        }
        return null
    }

    fun clear() {
        for (y in 0 until mapHeight) {
            for (x in 0 until mapWidth) {
                tileMap[y][x] = -1
            }
        }
    }
}
