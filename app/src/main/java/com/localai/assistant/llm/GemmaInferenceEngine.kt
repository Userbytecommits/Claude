package com.localai.assistant.llm

import android.content.Context
import android.net.Uri
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.LlmInference.LlmInferenceOptions
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession
import com.google.mediapipe.tasks.genai.llminference.LlmInferenceSession.LlmInferenceSessionOptions
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import kotlin.coroutines.resume

/**
 * Thin wrapper around MediaPipe's on-device LLM Inference API, used to run a locally
 * converted Gemma `.task` model (e.g. Gemma 3n E2B-it) fully offline: no network calls,
 * the prompt and the model weights never leave the device.
 *
 * The model file itself is NOT bundled in the APK (it is several GB and subject to its
 * own license on Kaggle/Hugging Face). The user picks it once via SAF; see MainActivity.
 */
class GemmaInferenceEngine(private val context: Context) {

    private var llmInference: LlmInference? = null
    private var session: LlmInferenceSession? = null

    val isLoaded: Boolean
        get() = llmInference != null

    /** Copies the user-picked .task file into app-private storage and loads it. */
    suspend fun loadModel(modelUri: Uri): Result<Unit> = runCatching {
        val localFile = File(context.filesDir, "model.task")
        context.contentResolver.openInputStream(modelUri)?.use { input ->
            FileOutputStream(localFile).use { output -> input.copyTo(output) }
        } ?: error("Could not open the selected model file")

        loadModelFromPath(localFile.absolutePath)
    }

    /**
     * Downloads a `.task` model directly from a URL (fallback for when another app's
     * download can't be reached via the file picker) and loads it once complete.
     */
    suspend fun downloadAndLoadModel(
        url: String,
        accessToken: String?,
        onProgress: (bytesRead: Long, totalBytes: Long) -> Unit,
    ): Result<Unit> {
        val destination = File(context.filesDir, "model.task")
        val downloadResult = ModelDownloader.download(url, accessToken, destination, onProgress)
        return withContext(kotlinx.coroutines.Dispatchers.IO) {
            downloadResult.mapCatching { loadModelFromPath(it.absolutePath) }
        }
    }

    /** Loads directly from an absolute path, e.g. a file already pushed via adb. */
    fun loadModelFromPath(path: String) {
        close()
        val options = LlmInferenceOptions.builder()
            .setModelPath(path)
            .setMaxTokens(1024)
            .build()
        val inference = LlmInference.createFromOptions(context, options)
        val sessionOptions = LlmInferenceSessionOptions.builder()
            .setTemperature(0.7f)
            .setTopK(40)
            .build()
        llmInference = inference
        session = LlmInferenceSession.createFromOptions(inference, sessionOptions)
    }

    /**
     * Runs one turn of the conversation and returns the full response.
     * [systemPrompt] is prepended only on the very first call of a fresh session.
     */
    suspend fun generate(prompt: String): String = suspendCancellableCoroutine { cont ->
        val activeSession = session ?: run {
            cont.resume("The model is not loaded yet. Tap \"Load model\" first.")
            return@suspendCancellableCoroutine
        }
        try {
            activeSession.addQueryChunk(prompt)
            val result = activeSession.generateResponse()
            cont.resume(result)
        } catch (t: Throwable) {
            cont.resume("Inference error: ${t.message}")
        }
    }

    fun close() {
        session?.close()
        llmInference?.close()
        session = null
        llmInference = null
    }
}
