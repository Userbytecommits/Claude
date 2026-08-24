package dev.game.engine.core

typealias EventListener<T> = (T) -> Unit

class EventSystem {
    private val listeners = mutableMapOf<String, MutableList<EventListener<Any>>>()

    fun <T : Any> subscribe(eventType: String, listener: EventListener<T>) {
        @Suppress("UNCHECKED_CAST")
        listeners.getOrPut(eventType) { mutableListOf() }.add(listener as EventListener<Any>)
    }

    fun <T : Any> unsubscribe(eventType: String, listener: EventListener<T>) {
        @Suppress("UNCHECKED_CAST")
        listeners[eventType]?.remove(listener as EventListener<Any>)
    }

    fun <T : Any> publish(eventType: String, data: T) {
        listeners[eventType]?.forEach { listener ->
            try {
                listener(data as Any)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun clear() {
        listeners.clear()
    }
}

sealed class GameEvent
data class EntityCollisionEvent(val entity1: Entity, val entity2: Entity) : GameEvent()
data class EntityDestroyedEvent(val entity: Entity) : GameEvent()
data class SceneLoadedEvent(val scene: Scene) : GameEvent()
data class CustomEvent(val eventName: String, val data: Any? = null) : GameEvent()
