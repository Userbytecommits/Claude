package com.localai.assistant

import android.app.Application
import com.localai.assistant.llm.GemmaInferenceEngine

/**
 * Holds the single, process-wide instance of the local LLM engine so the chat UI,
 * the voice-interaction session and the accessibility service can all share one
 * loaded model instead of each loading their own copy into memory.
 */
class AssistantApplication : Application() {

    lateinit var engine: GemmaInferenceEngine
        private set

    override fun onCreate() {
        super.onCreate()
        engine = GemmaInferenceEngine(this)
    }

    companion object {
        fun from(context: android.content.Context): AssistantApplication =
            context.applicationContext as AssistantApplication
    }
}
