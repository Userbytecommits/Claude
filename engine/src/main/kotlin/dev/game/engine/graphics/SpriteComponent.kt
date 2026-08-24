package dev.game.engine.graphics

import dev.game.engine.core.Component

class SpriteComponent : Component() {
    var spriteId: String = ""
    var tintColor: Int = 0xFFFFFFFF.toInt()
    var sortingOrder: Int = 0
    var flipX: Boolean = false
    var flipY: Boolean = false

    override fun onCreate() {
        super.onCreate()
    }
}
