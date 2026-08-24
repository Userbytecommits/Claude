package dev.game.engine.core

abstract class Component {
    lateinit var entity: Entity
        internal set

    var enabled: Boolean = true

    open fun onEnable() {}

    open fun onDisable() {}

    open fun onCreate() {}

    open fun onDestroy() {}

    open fun update(deltaTime: Float) {}

    open fun lateUpdate(deltaTime: Float) {}
}
