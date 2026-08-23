package com.localai.assistant.llm

import android.os.Environment
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Finds `.task` model files already sitting on the device - in particular the ones
 * Google's "AI Edge Gallery" app downloads into its own app-storage folder under
 * `Android/data/com.google.ai.edge.gallery/...`, which a normal file picker often can't
 * browse into. Requires "All files access" (MANAGE_EXTERNAL_STORAGE) to be granted first;
 * without it, `Environment.isExternalStorageManager()` is false and every candidate
 * directory will simply be unreadable, so this returns an empty list rather than crashing.
 */
object ModelFileScanner {

    private val CANDIDATE_ROOTS = listOf(
        "Android/data/com.google.ai.edge.gallery",
        "Android/data/com.google.mediapipe.examples.llminference",
        "Download",
        "Documents",
    )

    private const val MAX_DEPTH = 8
    private const val MAX_RESULTS = 25

    suspend fun findTaskFiles(): List<File> = withContext(Dispatchers.IO) {
        if (!Environment.isExternalStorageManager()) return@withContext emptyList()

        val root = Environment.getExternalStorageDirectory()
        val results = mutableListOf<File>()
        for (relative in CANDIDATE_ROOTS) {
            val dir = File(root, relative)
            if (dir.isDirectory) scan(dir, depth = 0, results)
            if (results.size >= MAX_RESULTS) break
        }
        results
    }

    private fun scan(dir: File, depth: Int, results: MutableList<File>) {
        if (depth > MAX_DEPTH || results.size >= MAX_RESULTS) return
        val children = dir.listFiles() ?: return
        for (child in children) {
            if (results.size >= MAX_RESULTS) return
            when {
                child.isDirectory -> scan(child, depth + 1, results)
                child.name.endsWith(".task", ignoreCase = true) -> results.add(child)
            }
        }
    }
}
