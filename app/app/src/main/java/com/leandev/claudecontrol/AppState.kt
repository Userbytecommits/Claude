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
    private const val KEY_WORKSPACE = "workspace_id"

    fun getModel(apiKey: String): String {
        val isOpenRouter = apiKey.startsWith("sk-or-") || (apiKey.startsWith("sk-") && !apiKey.startsWith("sk-ant-"))
        return if (isOpenRouter) "gpt-3.5-turbo" else "claude-sonnet-5"
    }

    const val MODEL = "claude-sonnet-5"

    var logCallback: ((String) -> Unit)? = null
    var serviceInstance: ControlAccessibilityService? = null

    fun log(msg: String) {
        logCallback?.invoke(msg)
    }

    fun save(context: Context, apiKey: String, goal: String, workspaceId: String = "") {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        prefs.edit()
            .putString(KEY_API, apiKey)
            .putString(KEY_GOAL, goal)
            .putString(KEY_WORKSPACE, workspaceId)
            .apply()
    }

    fun loadApiKey(context: Context): String {
        return prefs(context).getString(KEY_API, "") ?: ""
    }

    fun loadGoal(context: Context): String {
        return prefs(context).getString(KEY_GOAL, "") ?: ""
    }

    fun loadWorkspaceId(context: Context): String {
        return prefs(context).getString(KEY_WORKSPACE, "") ?: ""
    }

    private fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
