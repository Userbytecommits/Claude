package dev.game.engine.core

class GameState {
    private val variables = mutableMapOf<String, Any?>()

    fun setInt(key: String, value: Int) {
        variables[key] = value
    }

    fun getInt(key: String, default: Int = 0): Int {
        return (variables[key] as? Int) ?: default
    }

    fun setFloat(key: String, value: Float) {
        variables[key] = value
    }

    fun getFloat(key: String, default: Float = 0f): Float {
        return (variables[key] as? Float) ?: default
    }

    fun setString(key: String, value: String) {
        variables[key] = value
    }

    fun getString(key: String, default: String = ""): String {
        return (variables[key] as? String) ?: default
    }

    fun setBoolean(key: String, value: Boolean) {
        variables[key] = value
    }

    fun getBoolean(key: String, default: Boolean = false): Boolean {
        return (variables[key] as? Boolean) ?: default
    }

    fun set(key: String, value: Any?) {
        variables[key] = value
    }

    fun get(key: String): Any? {
        return variables[key]
    }

    fun has(key: String): Boolean {
        return key in variables
    }

    fun remove(key: String) {
        variables.remove(key)
    }

    fun clear() {
        variables.clear()
    }

    fun getAll(): Map<String, Any?> {
        return variables.toMap()
    }
}
