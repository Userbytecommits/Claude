package com.leandev.claudecontrol

import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * Ruft die Anthropic Messages API auf und erwartet eine Antwort im festen
 * JSON-Aktionsschema (siehe SYSTEM_PROMPT).
 */
object ClaudeApiClient {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build()

    private const val SYSTEM_PROMPT = """
Du steuerst ein Android-Gerät über den Accessibility-Tree (keine Bilder).
Du bekommst eine JSON-Liste sichtbarer/interaktiver UI-Elemente mit "index".
Antworte AUSSCHLIESSLICH mit einem JSON-Objekt, keine Erklärung, kein Markdown:
{
  "action": "tap" | "type" | "swipe_up" | "swipe_down" | "back" | "home" | "scroll_forward" | "scroll_backward" | "wait" | "done",
  "target_index": <int oder null>,
  "text": "<string oder null, nur bei action=type>",
  "reasoning": "<kurzer Grund, max 1 Satz>"
}
Nutze "done" wenn das Ziel erreicht ist. Nutze "target_index" passend zur gelieferten Element-Liste.
"""

    interface ResultCallback {
        fun onResult(action: JSONObject)
        fun onError(message: String)
    }

    fun requestNextAction(
        apiKey: String,
        goal: String,
        elements: JSONArray,
        history: List<String>,
        callback: ResultCallback
    ) {
        val userContent = JSONObject().apply {
            put("goal", goal)
            put("recent_actions", JSONArray(history.takeLast(5)))
            put("current_elements", elements)
        }

        val body = JSONObject().apply {
            put("model", AppState.MODEL)
            put("max_tokens", 500)
            put("system", SYSTEM_PROMPT)
            put("messages", JSONArray().put(
                JSONObject().apply {
                    put("role", "user")
                    put("content", userContent.toString())
                }
            ))
        }

        val mediaType = "application/json".toMediaType()
        val request = Request.Builder()
            .url("https://api.anthropic.com/v1/messages")
            .addHeader("x-api-key", apiKey)
            .addHeader("anthropic-version", "2023-06-01")
            .addHeader("content-type", "application/json")
            .post(body.toString().toRequestBody(mediaType))
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                callback.onError("Netzwerkfehler: ${e.message}")
            }

            override fun onResponse(call: Call, response: okhttp3.Response) {
                response.use {
                    val bodyStr = it.body?.string() ?: ""
                    if (!it.isSuccessful) {
                        callback.onError("API-Fehler ${it.code}: $bodyStr")
                        return
                    }
                    try {
                        val json = JSONObject(bodyStr)
                        val content = json.getJSONArray("content")
                        val text = StringBuilder()
                        for (i in 0 until content.length()) {
                            val block = content.getJSONObject(i)
                            if (block.optString("type") == "text") {
                                text.append(block.optString("text"))
                            }
                        }
                        var raw = text.toString().trim()
                        raw = raw.removePrefix("```json").removePrefix("```").removeSuffix("```").trim()
                        callback.onResult(JSONObject(raw))
                    } catch (e: Exception) {
                        callback.onError("Antwort konnte nicht geparst werden: ${e.message} | raw=$bodyStr")
                    }
                }
            }
        })
    }
}
