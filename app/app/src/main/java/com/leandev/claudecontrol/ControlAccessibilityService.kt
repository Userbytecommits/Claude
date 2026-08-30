package com.leandev.claudecontrol

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.graphics.Rect
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONArray
import org.json.JSONObject

class ControlAccessibilityService : AccessibilityService() {

    private val history = mutableListOf<String>()
    private var autoRunning = false
    private val handler = Handler(Looper.getMainLooper())
    private val interactiveNodes = mutableListOf<AccessibilityNodeInfo>()

    override fun onServiceConnected() {
        super.onServiceConnected()
        AppState.serviceInstance = this
        AppState.log("Accessibility-Service verbunden.")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) { /* nicht benötigt, pull-basiert */ }
    override fun onInterrupt() {}

    override fun onDestroy() {
        super.onDestroy()
        AppState.serviceInstance = null
        autoRunning = false
    }

    fun stopAuto() { autoRunning = false }

    fun runStep() {
        val apiKey = AppState.loadApiKey(applicationContext)
        val goal = AppState.loadGoal(applicationContext)
        val workspaceId = AppState.loadWorkspaceId(applicationContext)
        if (apiKey.isBlank() || goal.isBlank()) {
            AppState.log("Fehler: API-Key oder Ziel fehlt.")
            return
        }
        val elements = buildElementTree()
        AppState.log("Elemente erfasst: ${elements.length()}")

        ClaudeApiClient.requestNextAction(apiKey, workspaceId, goal, elements, history, object : ClaudeApiClient.ResultCallback {
            override fun onResult(action: JSONObject) {
                handler.post { executeAction(action) }
            }
            override fun onError(message: String) {
                AppState.log("Fehler: $message")
                autoRunning = false
            }
        })
    }

    fun runAutoLoop() {
        autoRunning = true
        loopStep()
    }

    private fun loopStep() {
        if (!autoRunning) return
        runStep()
        handler.postDelayed({ if (autoRunning) loopStep() }, 3000)
    }

    private fun buildElementTree(): JSONArray {
        interactiveNodes.clear()
        val root = rootInActiveWindow ?: return JSONArray()
        val result = JSONArray()
        collect(root, result)
        return result
    }

    private fun collect(node: AccessibilityNodeInfo, out: JSONArray) {
        if (node.isVisibleToUser && (node.isClickable || node.isEditable || !node.text.isNullOrBlank() || !node.contentDescription.isNullOrBlank())) {
            val bounds = Rect()
            node.getBoundsInScreen(bounds)
            val index = interactiveNodes.size
            interactiveNodes.add(node)
            out.put(JSONObject().apply {
                put("index", index)
                put("class", node.className ?: "")
                put("text", node.text ?: "")
                put("desc", node.contentDescription ?: "")
                put("clickable", node.isClickable)
                put("editable", node.isEditable)
                put("bounds", "${bounds.left},${bounds.top},${bounds.right},${bounds.bottom}")
            })
        }
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { collect(it, out) }
        }
    }

    private fun executeAction(action: JSONObject) {
        val type = action.optString("action")
        val targetIndex = if (action.isNull("target_index")) -1 else action.optInt("target_index", -1)
        val text = action.optString("text", "")
        val reasoning = action.optString("reasoning", "")
        AppState.log("Aktion: $type (idx=$targetIndex) - $reasoning")
        history.add("$type idx=$targetIndex text=$text")

        when (type) {
            "tap" -> targetIndex.takeIf { it in interactiveNodes.indices }?.let { tapNode(interactiveNodes[it]) }
            "type" -> targetIndex.takeIf { it in interactiveNodes.indices }?.let { setText(interactiveNodes[it], text) }
            "swipe_up" -> swipe(fromY = 1600, toY = 500)
            "swipe_down" -> swipe(fromY = 500, toY = 1600)
            "scroll_forward" -> targetIndex.takeIf { it in interactiveNodes.indices }?.let {
                interactiveNodes[it].performAction(AccessibilityNodeInfo.ACTION_SCROLL_FORWARD)
            }
            "scroll_backward" -> targetIndex.takeIf { it in interactiveNodes.indices }?.let {
                interactiveNodes[it].performAction(AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD)
            }
            "back" -> performGlobalAction(GLOBAL_ACTION_BACK)
            "home" -> performGlobalAction(GLOBAL_ACTION_HOME)
            "wait" -> { /* nichts tun, nächster Loop-Schritt kommt automatisch */ }
            "done" -> {
                AppState.log("Ziel als erreicht gemeldet.")
                autoRunning = false
            }
            else -> AppState.log("Unbekannte Aktion: $type")
        }
    }

    private fun tapNode(node: AccessibilityNodeInfo) {
        if (node.isClickable) {
            node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            return
        }
        val bounds = Rect()
        node.getBoundsInScreen(bounds)
        val path = Path().apply { moveTo(bounds.exactCenterX(), bounds.exactCenterY()) }
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 100))
            .build()
        dispatchGesture(gesture, null, null)
    }

    private fun setText(node: AccessibilityNodeInfo, text: String) {
        val args = Bundle()
        args.putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text)
        node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
    }

    private fun swipe(fromY: Int, toY: Int) {
        val path = Path().apply {
            moveTo(540f, fromY.toFloat())
            lineTo(540f, toY.toFloat())
        }
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 300))
            .build()
        dispatchGesture(gesture, null, null)
    }
}
