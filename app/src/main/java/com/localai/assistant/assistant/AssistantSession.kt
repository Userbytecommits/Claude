package com.localai.assistant.assistant

import android.app.assist.AssistContent
import android.app.assist.AssistStructure
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.service.voice.VoiceInteractionSession
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.localai.assistant.AssistantApplication
import com.localai.assistant.control.ActionExecutor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * The actual "assistant popped up over whatever you were doing" experience, equivalent
 * to Gemini's overlay sheet on Pixel. Shown whenever the user invokes the system assist
 * gesture while this app is set as the default Assistant app.
 */
class AssistantSession(context: Context) : VoiceInteractionSession(context) {

    private val scope = CoroutineScope(Dispatchers.Main)
    private lateinit var responseView: TextView
    private lateinit var input: EditText

    private var screenSummary: String = ""

    override fun onCreateContentView(): View {
        val root = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#1E1E27"))
            setPadding(32, 32, 32, 32)
        }

        val scroller = ScrollView(context).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f
            )
        }
        responseView = TextView(context).apply {
            setTextColor(Color.parseColor("#F2F2F7"))
            text = "Local assistant ready. What do you need?"
        }
        scroller.addView(responseView)
        root.addView(scroller)

        val row = LinearLayout(context).apply { orientation = LinearLayout.HORIZONTAL }
        input = EditText(context).apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            setTextColor(Color.parseColor("#F2F2F7"))
            hint = "Ask or tell the assistant to do something…"
        }
        val send = Button(context).apply {
            text = "Send"
            setOnClickListener { submit(input.text.toString()) }
        }
        row.addView(input)
        row.addView(send)
        root.addView(row)

        root.gravity = Gravity.BOTTOM
        return root
    }

    /** Captures a light-weight summary of what the user was looking at when they invoked assist. */
    override fun onHandleAssist(data: Bundle?, structure: AssistStructure?, content: AssistContent?) {
        super.onHandleAssist(data, structure, content)
        screenSummary = buildString {
            structure?.let { append("Foreground app: ${it.activityComponent?.packageName ?: "unknown"}. ") }
            content?.structuredData?.let { append("Structured data available. ") }
        }
    }

    private fun submit(userText: String) {
        if (userText.isBlank()) return
        responseView.text = "${responseView.text}\n\nYou: $userText"
        input.setText("")

        val engine = AssistantApplication.from(context).engine
        scope.launch {
            val prompt = buildPrompt(userText)
            val raw = engine.generate(prompt)
            val result = ActionExecutor.process(context, raw)
            responseView.text = "${responseView.text}\n\nAssistant: ${result.displayText}"
        }
    }

    private fun buildPrompt(userText: String): String = buildString {
        appendLine(SYSTEM_PROMPT)
        if (screenSummary.isNotBlank()) appendLine("Context: $screenSummary")
        append("User: ")
        append(userText)
    }

    override fun onHide() {
        super.onHide()
    }

    companion object {
        const val SYSTEM_PROMPT = """You are a helpful, on-device phone assistant, similar to Google Assistant/Gemini on a Pixel phone.
When the user asks you to DO something on the phone (open a settings screen, go back/home, read the screen, read recent notifications, tap a button), respond with a short natural-language acknowledgement AND append exactly one tag on its own line in this format:
[ACTION:NAME key=value]
Valid NAMEs: OPEN_SETTINGS (target=wifi|bluetooth|volume|display|battery|date|accessibility|security|nfc), OPEN_APP_SETTINGS (target=<package name>), TAP (target=<visible label>), GO_BACK, GO_HOME, OPEN_RECENTS, OPEN_QUICK_SETTINGS, READ_SCREEN, READ_NOTIFICATIONS.
If the user is just asking a question, answer normally and do not include any [ACTION:...] tag."""
    }
}
