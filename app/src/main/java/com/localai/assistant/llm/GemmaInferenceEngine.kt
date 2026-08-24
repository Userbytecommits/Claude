package com.localai.assistant.llm

import android.content.Context
import android.net.Uri
import com.google.ai.edge.litertlm.Backend
import com.google.ai.edge.litertlm.Content
import com.google.ai.edge.litertlm.Contents
import com.google.ai.edge.litertlm.Conversation
import com.google.ai.edge.litertlm.ConversationConfig
import com.google.ai.edge.litertlm.Engine
import com.google.ai.edge.litertlm.EngineConfig
import com.google.ai.edge.litertlm.ExperimentalApi
import com.google.ai.edge.litertlm.Message
import com.google.ai.edge.litertlm.MessageCallback
import com.google.ai.edge.litertlm.SamplerConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import kotlin.coroutines.resume

/**
 * Thin wrapper around Google's LiteRT-LM runtime - the same one the official "AI Edge
 * Gallery" app uses - to run a locally downloaded Gemma `.litertlm` model (e.g.
 * Gemma 4 E2B-it) fully offline: no network calls, the prompt and the model weights
 * never leave the device.
 *
 * The model file itself is NOT bundled in the APK (it is multiple GB and gated behind
 * Google's model license on Hugging Face). See [ModelDownloader] / MainActivity for how
 * the user gets one in.
 */
class GemmaInferenceEngine(private val context: Context) {

    private var engine: Engine? = null
    private var conversation: Conversation? = null

    val isLoaded: Boolean
        get() = engine != null

    /** Copies the user-picked model file into app-private storage and loads it. */
    suspend fun loadModel(modelUri: Uri): Result<Unit> = runCatching {
        val localFile = File(context.filesDir, "model.litertlm")
        context.contentResolver.openInputStream(modelUri)?.use { input ->
            FileOutputStream(localFile).use { output -> input.copyTo(output) }
        } ?: error("Could not open the selected model file")

        loadModelFromPath(localFile.absolutePath)
    }

    /**
     * Downloads a `.litertlm` model directly from a URL and loads it once complete.
     */
    suspend fun downloadAndLoadModel(
        url: String,
        accessToken: String?,
        onProgress: (bytesRead: Long, totalBytes: Long) -> Unit,
    ): Result<Unit> {
        val destination = File(context.filesDir, "model.litertlm")
        val downloadResult = ModelDownloader.download(url, accessToken, destination, onProgress)
        return withContext(Dispatchers.IO) {
            downloadResult.mapCatching { loadModelFromPath(it.absolutePath) }
        }
    }

    /** Loads directly from an absolute path, e.g. a file already pushed via adb. */
    @OptIn(ExperimentalApi::class)
    fun loadModelFromPath(path: String) {
        close()
        val engineConfig = EngineConfig(
            modelPath = path,
            backend = Backend.CPU(),
            maxNumTokens = 1024,
        )
        val newEngine = Engine(engineConfig)
        newEngine.initialize()
        val newConversation = newEngine.createConversation(
            ConversationConfig(
                samplerConfig = SamplerConfig(topK = 40, topP = 0.9, temperature = 0.7),
            )
        )
        engine = newEngine
        conversation = newConversation
    }

    /** Runs one turn of the conversation and returns the full response. */
    suspend fun generate(prompt: String): String = suspendCancellableCoroutine { cont ->
        val activeConversation = conversation ?: run {
            cont.resume("The model is not loaded yet. Load a model first.")
            return@suspendCancellableCoroutine
        }
        val sb = StringBuilder()
        activeConversation.sendMessageAsync(
            Contents.of(listOf(Content.Text(prompt))),
            object : MessageCallback {
                override fun onMessage(message: Message) {
                    sb.append(message.toString())
                }

                override fun onDone() {
                    if (cont.isActive) cont.resume(sb.toString())
                }

                override fun onError(throwable: Throwable) {
                    if (cont.isActive) cont.resume("Inference error: ${throwable.message}")
                }
            },
            emptyMap(),
        )
    }

    fun close() {
        conversation?.close()
        engine?.close()
        conversation = null
        engine = null
    }
}
