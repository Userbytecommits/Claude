package com.localai.assistant.control

import android.content.Context
import android.content.Intent
import android.provider.Settings

/**
 * Opens system Settings screens/panels for the assistant. Modern Android does not let a
 * regular app silently flip Wi-Fi/Bluetooth/etc. on the user's behalf (that was removed
 * for privacy/security reasons since API 29) - instead the OS-sanctioned way is to open
 * the relevant Settings panel or screen, which is exactly what Gemini/Assistant does too.
 * For a true one-tap toggle, DeviceControlAccessibilityService can additionally tap the
 * matching Quick Settings tile once the panel is open.
 */
object SettingsController {

    fun openWifiSettings(context: Context) = openPanel(context, Settings.Panel.ACTION_WIFI)

    fun openBluetoothSettings(context: Context) = openScreen(context, Settings.ACTION_BLUETOOTH_SETTINGS)

    fun openVolumeSettings(context: Context) = openPanel(context, Settings.Panel.ACTION_VOLUME)

    fun openNfcSettings(context: Context) = openPanel(context, Settings.Panel.ACTION_NFC)

    fun openAppSettings(context: Context, packageName: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = android.net.Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    fun openDisplaySettings(context: Context) = openScreen(context, Settings.ACTION_DISPLAY_SETTINGS)
    fun openBatterySettings(context: Context) = openScreen(context, Settings.ACTION_BATTERY_SAVER_SETTINGS)
    fun openSoundSettings(context: Context) = openScreen(context, Settings.ACTION_SOUND_SETTINGS)
    fun openDateTimeSettings(context: Context) = openScreen(context, Settings.ACTION_DATE_SETTINGS)
    fun openAccessibilitySettings(context: Context) = openScreen(context, Settings.ACTION_ACCESSIBILITY_SETTINGS)
    fun openNotificationListenerSettings(context: Context) =
        openScreen(context, "android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
    fun openDefaultAssistantSettings(context: Context) =
        openScreen(context, Settings.ACTION_VOICE_INPUT_SETTINGS)
    fun openWirelessSettings(context: Context) = openScreen(context, Settings.ACTION_WIRELESS_SETTINGS)
    fun openSecuritySettings(context: Context) = openScreen(context, Settings.ACTION_SECURITY_SETTINGS)

    private fun openPanel(context: Context, action: String) {
        val intent = Intent(action).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        context.startActivity(intent)
    }

    private fun openScreen(context: Context, action: String) {
        val intent = Intent(action).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        context.startActivity(intent)
    }
}
