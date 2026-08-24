package com.localai.assistant.llm

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

/**
 * Downloads a `.litertlm` (or `.task`, for older Gemma 3n releases) model file directly
 * from a Hugging Face URL, so the app doesn't depend on another app (e.g. AI Edge Gallery)
 * having already downloaded a copy the user can find.
 *
 * Gated models (all current Gemma releases) require the request to carry the user's own
 * Hugging Face access token; without one the download will fail with a 401/403, which is
 * reported back rather than silently retried.
 */
object ModelDownloader {

    suspend fun download(
        url: String,
        accessToken: String?,
        destination: File,
        onProgress: (bytesRead: Long, totalBytes: Long) -> Unit,
    ): Result<File> = withContext(Dispatchers.IO) {
        runCatching {
            var currentUrl = url
            var connection: HttpURLConnection
            var redirects = 0
            while (true) {
                connection = (URL(currentUrl).openConnection() as HttpURLConnection).apply {
                    connectTimeout = 15_000
                    readTimeout = 15_000
                    if (!accessToken.isNullOrBlank()) setRequestProperty("Authorization", "Bearer $accessToken")
                    instanceFollowRedirects = false
                }
                val code = connection.responseCode
                if (code in 300..399 && redirects < 5) {
                    val location = connection.getHeaderField("Location") ?: error("Redirect with no Location header")
                    connection.disconnect()
                    currentUrl = location
                    redirects++
                    continue
                }
                if (code != HttpURLConnection.HTTP_OK) {
                    val body = connection.errorStream?.bufferedReader()?.readText().orEmpty()
                    error("Download failed: HTTP $code ${connection.responseMessage}. $body")
                }
                break
            }

            val total = connection.contentLengthLong
            var readSoFar = 0L
            val tmpFile = File(destination.parentFile, destination.name + ".part")

            connection.inputStream.use { input ->
                tmpFile.outputStream().use { output ->
                    val buffer = ByteArray(1 shl 16)
                    while (true) {
                        val read = input.read(buffer)
                        if (read == -1) break
                        output.write(buffer, 0, read)
                        readSoFar += read
                        onProgress(readSoFar, total)
                    }
                }
            }
            connection.disconnect()

            if (!tmpFile.renameTo(destination)) error("Could not finalize downloaded file")
            destination
        }
    }
}
