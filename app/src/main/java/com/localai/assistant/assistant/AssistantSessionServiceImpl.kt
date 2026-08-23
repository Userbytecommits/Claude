package com.localai.assistant.assistant

import android.os.Bundle
import android.service.voice.VoiceInteractionSession
import android.service.voice.VoiceInteractionSessionService

/**
 * Creates a fresh [AssistantSession] every time the assistant is invoked (long-press
 * power button / home gesture / "Hey Assistant"-style trigger, depending on OEM), the
 * same hook point Gemini/Assistant uses on Pixel.
 */
class AssistantSessionServiceImpl : VoiceInteractionSessionService() {
    override fun onNewSession(args: Bundle?): VoiceInteractionSession =
        AssistantSession(this)
}
