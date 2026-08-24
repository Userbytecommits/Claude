package dev.game.engine.core

import dev.game.engine.utils.Vector2

class Entity(var name: String = "Entity") {
    var position = Vector2(0f, 0f)
    var rotation = 0f
    var scale = Vector2(1f, 1f)
    var active = true

    private val components = mutableListOf<Component>()
    private var destroyed = false

    fun addComponent(component: Component): Component {
        component.entity = this
        components.add(component)
        component.onCreate()
        if (active) {
            component.onEnable()
        }
        return component
    }

    fun removeComponent(component: Component) {
        if (components.remove(component)) {
            if (active) {
                component.onDisable()
            }
            component.onDestroy()
        }
    }

    inline fun <reified T : Component> getComponent(): T? {
        return components.filterIsInstance<T>().firstOrNull()
    }

    inline fun <reified T : Component> getComponents(): List<T> {
        return components.filterIsInstance<T>()
    }

    internal fun updateComponents(deltaTime: Float) {
        if (!active || destroyed) return
        components.filter { it.enabled }.forEach { it.update(deltaTime) }
    }

    internal fun lateUpdateComponents(deltaTime: Float) {
        if (!active || destroyed) return
        components.filter { it.enabled }.forEach { it.lateUpdate(deltaTime) }
    }

    fun destroy() {
        if (!destroyed) {
            destroyed = true
            components.forEach {
                if (active) {
                    it.onDisable()
                }
                it.onDestroy()
            }
            components.clear()
        }
    }

    fun isDestroyed(): Boolean = destroyed
}
