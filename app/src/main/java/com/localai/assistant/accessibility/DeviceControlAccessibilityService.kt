package com.localai.assistant.accessibility

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Gives the assistant "hands and eyes" on the device: it can read what is currently on
 * screen (via the accessibility node tree) and perform taps, scrolls, back/home/recents,
 * and open the Quick Settings panel. This mirrors what Gemini/Assistant on Pixel can do
 * when it controls the phone for you.
 *
 * The user must explicitly enable this service in Settings > Accessibility; Android does
 * not allow an app to grant this permission to itself.
 */
class DeviceControlAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        super.onDestroy()
        if (instance === this) instance = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // No continuous event handling needed; actions are performed on demand
        // via the companion object from ActionExecutor.
    }

    override fun onInterrupt() {}

    /** Dumps a flattened, readable summary of the text currently visible on screen. */
    fun readScreenText(): String {
        val root = rootInActiveWindow ?: return "(no active window)"
        val sb = StringBuilder()
        collectText(root, sb)
        return sb.toString().ifBlank { "(screen has no readable text)" }
    }

    private fun collectText(node: AccessibilityNodeInfo, out: StringBuilder) {
        node.text?.let { if (it.isNotBlank()) out.appendLine(it) }
        node.contentDescription?.let { if (it.isNotBlank()) out.appendLine(it) }
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { collectText(it, out) }
        }
    }

    /** Finds the first clickable node whose text/contentDescription contains [label] and taps it. */
    fun tapByLabel(label: String): Boolean {
        val root = rootInActiveWindow ?: return false
        val target = findNodeByLabel(root, label.lowercase()) ?: return false
        return performClickOnOrAncestor(target)
    }

    private fun findNodeByLabel(node: AccessibilityNodeInfo, label: String): AccessibilityNodeInfo? {
        val text = node.text?.toString()?.lowercase().orEmpty()
        val desc = node.contentDescription?.toString()?.lowercase().orEmpty()
        if (text.contains(label) || desc.contains(label)) return node
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { child ->
                findNodeByLabel(child, label)?.let { return it }
            }
        }
        return null
    }

    private fun performClickOnOrAncestor(node: AccessibilityNodeInfo): Boolean {
        var current: AccessibilityNodeInfo? = node
        while (current != null) {
            if (current.isClickable) {
                return current.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            }
            current = current.parent
        }
        return false
    }

    fun tapAt(x: Float, y: Float): Boolean {
        val path = Path().apply { moveTo(x, y) }
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 50))
            .build()
        return dispatchGesture(gesture, null, null)
    }

    fun pressBack(): Boolean = performGlobalAction(GLOBAL_ACTION_BACK)
    fun pressHome(): Boolean = performGlobalAction(GLOBAL_ACTION_HOME)
    fun openRecents(): Boolean = performGlobalAction(GLOBAL_ACTION_RECENTS)
    fun openNotifications(): Boolean = performGlobalAction(GLOBAL_ACTION_NOTIFICATIONS)
    fun openQuickSettings(): Boolean = performGlobalAction(GLOBAL_ACTION_QUICK_SETTINGS)

    companion object {
        /** Null until the user has enabled the service; every action gracefully no-ops until then. */
        var instance: DeviceControlAccessibilityService? = null
            private set
    }
}
