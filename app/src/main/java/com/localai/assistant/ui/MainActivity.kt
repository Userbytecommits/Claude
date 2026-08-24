package com.localai.assistant.ui

import android.app.AlertDialog
import android.app.role.RoleManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.localai.assistant.AssistantApplication
import com.localai.assistant.control.ActionExecutor
import com.localai.assistant.databinding.ActivityMainBinding
import kotlinx.coroutines.launch

/**
 * The regular app UI: load the Gemma model, grant the assistant its permissions, and
 * chat with it directly (in addition to invoking it as the system Assistant, see
 * [com.localai.assistant.assistant.AssistantSession]).
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: ChatAdapter

    private val pickModel = registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri: Uri? ->
        if (uri == null) return@registerForActivityResult
        contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        binding.txtStatus.text = "Loading model…"
        lifecycleScope.launch {
            val result = AssistantApplication.from(this@MainActivity).engine.loadModel(uri)
            binding.txtStatus.text = if (result.isSuccess) "Model loaded." else "Failed: ${result.exceptionOrNull()?.message}"
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        adapter = ChatAdapter()
        binding.recyclerChat.layoutManager = LinearLayoutManager(this)
        binding.recyclerChat.adapter = adapter

        binding.btnLoadModel.setOnClickListener {
            pickModel.launch(arrayOf("*/*"))
        }

        binding.btnDownloadModel.setOnClickListener { showDownloadModelDialog() }

        binding.btnAccessibility.setOnClickListener {
            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
        }

        binding.btnDefaultAssistant.setOnClickListener { requestAssistantRole() }

        binding.btnSend.setOnClickListener {
            val text = binding.editInput.text.toString()
            if (text.isNotBlank()) {
                binding.editInput.setText("")
                sendMessage(text)
            }
        }

        val engine = AssistantApplication.from(this).engine
        binding.txtStatus.text = if (engine.isLoaded) "Model loaded." else getString(com.localai.assistant.R.string.hint_model_missing)
    }

    /**
     * Downloads the model straight from Hugging Face - the exact same source and file
     * layout the official "AI Edge Gallery" app uses - instead of relying on finding a
     * copy that app already downloaded. Only a Hugging Face access token is needed since
     * every current Gemma release is a gated model; the repo id/filename are prefilled
     * with the confirmed Gemma 4 E2B-it values and can be swapped for another variant.
     */
    private fun showDownloadModelDialog() {
        val padding = (16 * resources.displayMetrics.density).toInt()
        val info = TextView(this).apply {
            text = "Downloads directly from Hugging Face (litert-community). " +
                "Needs a free Hugging Face account: accept the model's license on its page, " +
                "then create a token under Settings > Access Tokens and paste it below."
        }
        val repoInput = EditText(this).apply {
            hint = "Hugging Face repo id"
            setText(DEFAULT_MODEL_REPO)
        }
        val fileInput = EditText(this).apply {
            hint = "Model filename"
            setText(DEFAULT_MODEL_FILE)
        }
        val tokenInput = EditText(this).apply {
            hint = getString(com.localai.assistant.R.string.dialog_download_token_hint)
        }
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(padding, padding, padding, padding)
            gravity = Gravity.CENTER_HORIZONTAL
            addView(info)
            addView(repoInput)
            addView(fileInput)
            addView(tokenInput)
        }

        AlertDialog.Builder(this)
            .setTitle(com.localai.assistant.R.string.dialog_download_title)
            .setView(container)
            .setPositiveButton(com.localai.assistant.R.string.btn_download_model) { _, _ ->
                val repo = repoInput.text.toString().trim()
                val file = fileInput.text.toString().trim()
                val token = tokenInput.text.toString().trim().ifBlank { null }
                if (repo.isNotBlank() && file.isNotBlank()) {
                    val url = "https://huggingface.co/$repo/resolve/main/$file?download=true"
                    downloadModel(url, token)
                }
            }
            .setNegativeButton(android.R.string.cancel, null)
            .show()
    }

    private fun downloadModel(url: String, token: String?) {
        val engine = AssistantApplication.from(this).engine
        lifecycleScope.launch {
            val result = engine.downloadAndLoadModel(url, token) { read, total ->
                val percent = if (total > 0) " (${read * 100 / total}%)" else ""
                runOnUiThread { binding.txtStatus.text = "Downloading model$percent…" }
            }
            binding.txtStatus.text = if (result.isSuccess) {
                "Model downloaded and loaded."
            } else {
                "Download failed: ${result.exceptionOrNull()?.message}"
            }
        }
    }

    private fun requestAssistantRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            if (roleManager.isRoleAvailable(RoleManager.ROLE_ASSISTANT)) {
                if (!roleManager.isRoleHeld(RoleManager.ROLE_ASSISTANT)) {
                    startActivity(roleManager.createRequestRoleIntent(RoleManager.ROLE_ASSISTANT))
                    return
                }
            }
        }
        // Fallback for devices/OEMs that manage the assistant role from plain Settings.
        startActivity(Intent(Settings.ACTION_VOICE_INPUT_SETTINGS))
    }

    private fun sendMessage(userText: String) {
        adapter.submit(ChatMessage(ChatMessage.Author.USER, userText))
        binding.recyclerChat.scrollToPosition(adapter.itemCount - 1)
        adapter.submit(ChatMessage(ChatMessage.Author.ASSISTANT, "…"))

        lifecycleScope.launch {
            val engine = AssistantApplication.from(this@MainActivity).engine
            val prompt = "${com.localai.assistant.assistant.AssistantSession.SYSTEM_PROMPT}\nUser: $userText"
            val raw = engine.generate(prompt)
            val result = ActionExecutor.process(this@MainActivity, raw)
            adapter.updateLast(result.displayText)
            binding.recyclerChat.scrollToPosition(adapter.itemCount - 1)
        }
    }

    companion object {
        // Confirmed from the AI Edge Gallery app's own source: this is the exact
        // Hugging Face repo/file the "Gemma-4-E2B-it" download button there fetches.
        private const val DEFAULT_MODEL_REPO = "litert-community/gemma-4-E2B-it-litert-lm"
        private const val DEFAULT_MODEL_FILE = "gemma-4-E2B-it.litertlm"
    }
}
