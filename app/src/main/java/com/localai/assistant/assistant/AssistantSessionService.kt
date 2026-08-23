package com.localai.assistant.assistant

import android.service.voice.VoiceInteractionService

/**
 * Marker service Android binds to when this app is selected as the device's default
 * Assistant app (Settings > Apps > Default apps > Digital assistant app). The actual
 * per-invocation UI lives in [AssistantSessionServiceImpl] / [AssistantSession].
 */
class AssistantSessionService : VoiceInteractionService()
