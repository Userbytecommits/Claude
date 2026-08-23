package com.localai.assistant.llm

import android.os.Environment
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Finds model files another app (typically Google's "AI Edge Gallery") already downloaded
 * onto the device, so the user doesn't need a direct URL. Matches by *size* rather than a
 * fixed extension: on-device Gemma model bundles are always well over 100 MB regardless of
 * whether they ship as `.task` (MediaPipe LLM Inference) or another LiteRT-LM container
 * extension, so filtering by size is far more robust than guessing the exact suffix.
 */
object ModelFileScanner {

    sealed interface ScanResult {
        data class Found(val files: List<File>) : ScanResult
        /** All-files-access was never granted, so every candidate directory is unreadable. */
        object NoPermission : ScanResult
        /** Permission is fine, but nothing over [MIN_MODEL_SIZE_BYTES] turned up anywhere scanned. */
        data class NothingFound(val scannedDirs: List<String>) : ScanResult
    }

    private const val MIN_MODEL_SIZE_BYTES = 150L * 1024 * 1024 // 150 MB
    private const val MAX_DEPTH = 10
    private const val MAX_RESULTS = 25

    /** Roots we know or strongly suspect an on-device model manager writes into. */
    private val NAMED_ROOTS = listOf(
        "Android/data/com.google.ai.edge.gallery",
        "Android/data/com.google.mediapipe.examples.llminference",
        "Download",
        "Documents",
    )

    suspend fun scan(): ScanResult = withContext(Dispatchers.IO) {
        if (!Environment.isExternalStorageManager()) return@withContext ScanResult.NoPermission

        val storageRoot = Environment.getExternalStorageDirectory()
        val results = mutableListOf<File>()
        val scannedDirs = mutableListOf<String>()

        for (relative in NAMED_ROOTS) {
            val dir = File(storageRoot, relative)
            if (dir.isDirectory) {
                scannedDirs.add(dir.absolutePath)
                walk(dir, depth = 0, results)
            }
        }

        // Fallback: any other Android/data/<pkg> folder whose name hints at "edge"/"gallery"/
        // "gemma"/"llm", in case the real package name differs from what we guessed above.
        val androidData = File(storageRoot, "Android/data")
        androidData.listFiles()?.forEach { pkgDir ->
            val name = pkgDir.name.lowercase()
            val alreadyScanned = scannedDirs.any { it == pkgDir.absolutePath }
            if (!alreadyScanned && pkgDir.isDirectory &&
                ("edge" in name || "gallery" in name || "gemma" in name || "genai" in name || "llm" in name)
            ) {
                scannedDirs.add(pkgDir.absolutePath)
                walk(pkgDir, depth = 0, results)
            }
        }

        if (results.isEmpty()) ScanResult.NothingFound(scannedDirs) else ScanResult.Found(results)
    }

    private fun walk(dir: File, depth: Int, results: MutableList<File>) {
        if (depth > MAX_DEPTH || results.size >= MAX_RESULTS) return
        val children = dir.listFiles() ?: return
        for (child in children) {
            if (results.size >= MAX_RESULTS) return
            if (child.isDirectory) {
                walk(child, depth + 1, results)
            } else if (child.length() >= MIN_MODEL_SIZE_BYTES) {
                results.add(child)
            }
        }
    }
}
