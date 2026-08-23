package com.localai.assistant.notifications

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import java.util.ArrayDeque

/**
 * Lets the assistant "read notifications" (e.g. "what did I just get from WhatsApp?") the
 * same way Gemini/Assistant can summarize incoming messages. Keeps only a small in-memory
 * ring buffer of recent notification titles/text - nothing is persisted or sent anywhere.
 *
 * Requires the user to grant Notification access manually in Settings > Notifications >
 * Special app access > Notification access.
 */
class NotificationReaderService : NotificationListenerService() {

    override fun onListenerConnected() {
        super.onListenerConnected()
        instance = this
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        if (instance === this) instance = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString().orEmpty()
        val text = extras.getCharSequence("android.text")?.toString().orEmpty()
        if (title.isBlank() && text.isBlank()) return

        synchronized(recent) {
            if (recent.size >= MAX_HISTORY) recent.removeLast()
            recent.addFirst(NotificationEntry(sbn.packageName, title, text, sbn.postTime))
        }
    }

    fun recentAsText(limit: Int = 10): String = synchronized(recent) {
        if (recent.isEmpty()) return "No notifications captured yet."
        recent.take(limit).joinToString("\n") { "[${it.packageName}] ${it.title}: ${it.text}" }
    }

    data class NotificationEntry(
        val packageName: String,
        val title: String,
        val text: String,
        val postedAtMillis: Long,
    )

    companion object {
        private const val MAX_HISTORY = 50
        private val recent = ArrayDeque<NotificationEntry>()

        var instance: NotificationReaderService? = null
            private set
    }
}
