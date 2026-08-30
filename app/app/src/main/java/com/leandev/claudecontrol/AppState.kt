package com.leandev.claudecontrol

import android.content.Context
import android.content.SharedPreferences

/**
 * Zentraler Zustand: API-Key, Ziel, Logging.
 * Bewusst simpel gehalten (keine Verschlüsselung) - für private/lokale Nutzung.
 */
object AppState {
    private const val PREFS = "claude_control_prefs"
    private const val KEY_API = "api_key"
    private const val KEY_GOAL = "goal"
    const val MODEL = "claude-sonnet-5"

    var logCallback: ((String) -> Unit)? = null
    var serviceInstance: ControlAccessibilityService? = null

    fun log(msg: String) {
        logCallback?.invoke(msg)
    }

    fun save(context: Context, apiKey: String, goal: String) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_API, apiKey).putString(KEY_GOAL, goal).apply()
    }

    fun loadApiKey(context: Context): String {
        return prefs(context).getString(KEY_API, "") ?: ""
    }

    fun loadGoal(context: Context): String {
        return prefs(context).getString(KEY_GOAL, "") ?: ""
    }

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
