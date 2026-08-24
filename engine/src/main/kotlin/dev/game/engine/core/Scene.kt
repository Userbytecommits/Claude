package dev.game.engine.core

class Scene(val name: String = "Scene") {
    private val entities = mutableListOf<Entity>()

    fun addEntity(entity: Entity) {
        entities.add(entity)
    }

    fun removeEntity(entity: Entity) {
        entities.remove(entity)
        entity.destroy()
    }

    fun findEntity(name: String): Entity? {
        return entities.find { it.name == name }
    }

    fun getEntities(): List<Entity> = entities.toList()

    internal fun update(deltaTime: Float) {
        entities.filter { !it.isDestroyed() }.forEach { it.updateComponents(deltaTime) }
    }

    internal fun lateUpdate(deltaTime: Float) {
        entities.filter { !it.isDestroyed() }.forEach { it.lateUpdateComponents(deltaTime) }
    }

    internal fun cleanup() {
        entities.removeAll { it.isDestroyed() }
    }

    fun clear() {
        entities.forEach { it.destroy() }
        entities.clear()
    }
}
