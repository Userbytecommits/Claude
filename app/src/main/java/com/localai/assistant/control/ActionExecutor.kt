package com.localai.assistant.control

import android.content.Context
import com.localai.assistant.accessibility.DeviceControlAccessibilityService
import com.localai.assistant.notifications.NotificationReaderService

/**
 * Very small "function calling" layer: the system prompt (see MainActivity) instructs the
 * model to emit a line like `[ACTION:OPEN_SETTINGS target=wifi]` when the user asked it to
 * do something rather than just answer in text. This class recognizes those tags in the
 * model's reply, executes the matching device action, and strips the tag out of what is
 * shown to the user.
 *
 * Supported actions on purpose stay conservative (open a settings screen, tap a visible
 * label, read the screen/notifications) rather than silently changing security-sensitive
 * settings - the same boundary Google's own Assistant respects.
 */
object ActionExecutor {

    private val actionRegex = Regex("""\[ACTION:([A-Z_]+)(?:\s+([^\]]*))?]""")

    data class ExecutionResult(val displayText: String, val actionsRun: List<String>)

    fun process(context: Context, modelOutput: String): ExecutionResult {
        val actionsRun = mutableListOf<String>()

        val cleaned = actionRegex.replace(modelOutput) { match ->
            val action = match.groupValues[1]
            val argsRaw = match.groupValues[2]
            val args = parseArgs(argsRaw)
            actionsRun += runAction(context, action, args)
            ""
        }.trim()

        return ExecutionResult(cleaned.ifBlank { "Done." }, actionsRun)
    }

    private fun parseArgs(raw: String): Map<String, String> {
        if (raw.isBlank()) return emptyMap()
        val argRegex = Regex("""(\w+)=("[^"]*"|\S+)""")
        return argRegex.findAll(raw).associate { m ->
            m.groupValues[1] to m.groupValues[2].trim('"')
        }
    }

    private fun runAction(context: Context, action: String, args: Map<String, String>): String {
        val target = args["target"].orEmpty()
        return when (action) {
            "OPEN_SETTINGS" -> {
                when (target.lowercase()) {
                    "wifi" -> SettingsController.openWifiSettings(context)
                    "bluetooth" -> SettingsController.openBluetoothSettings(context)
                    "volume", "sound" -> SettingsController.openSoundSettings(context)
                    "display" -> SettingsController.openDisplaySettings(context)
                    "battery" -> SettingsController.openBatterySettings(context)
                    "date", "time" -> SettingsController.openDateTimeSettings(context)
                    "accessibility" -> SettingsController.openAccessibilitySettings(context)
                    "security" -> SettingsController.openSecuritySettings(context)
                    "nfc" -> SettingsController.openNfcSettings(context)
                    else -> SettingsController.openWirelessSettings(context)
                }
                "opened settings: $target"
            }

            "OPEN_APP_SETTINGS" -> {
                SettingsController.openAppSettings(context, target)
                "opened app settings for $target"
            }

            "TAP" -> {
                val ok = DeviceControlAccessibilityService.instance?.tapByLabel(target) ?: false
                if (ok) "tapped '$target'" else "could not find/tap '$target' (is the Accessibility service enabled?)"
            }

            "GO_BACK" -> {
                DeviceControlAccessibilityService.instance?.pressBack()
                "pressed back"
            }

            "GO_HOME" -> {
                DeviceControlAccessibilityService.instance?.pressHome()
                "went home"
            }

            "OPEN_RECENTS" -> {
                DeviceControlAccessibilityService.instance?.openRecents()
                "opened recents"
            }

            "OPEN_QUICK_SETTINGS" -> {
                DeviceControlAccessibilityService.instance?.openQuickSettings()
                "opened quick settings"
            }

            "READ_SCREEN" -> DeviceControlAccessibilityService.instance?.readScreenText()
                ?: "Accessibility service is not enabled."

            "READ_NOTIFICATIONS" -> NotificationReaderService.instance?.recentAsText()
                ?: "Notification access is not enabled."

            else -> "unknown action: $action"
        }
    }
}
