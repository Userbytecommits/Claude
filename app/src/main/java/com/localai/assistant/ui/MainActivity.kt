package com.localai.assistant.ui

import android.app.AlertDialog
import android.app.role.RoleManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.Settings
import android.view.Gravity
import android.widget.EditText
import android.widget.LinearLayout
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.localai.assistant.AssistantApplication
import com.localai.assistant.control.ActionExecutor
import com.localai.assistant.databinding.ActivityMainBinding
import com.localai.assistant.llm.ModelFileScanner
import kotlinx.coroutines.launch

/**
 * The regular app UI: load the Gemma model, grant the assistant its permissions, and
 * chat with it directly (in addition to invoking it as the system Assistant, see
 * [com.localai.assistant.assistant.AssistantSession]).
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var adapter: ChatAdapter
    private var pendingFindModelScan = false

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
        binding.btnFindModel.setOnClickListener { findModelOnDevice() }

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

    override fun onResume() {
        super.onResume()
        if (pendingFindModelScan && hasAllFilesAccess()) {
            pendingFindModelScan = false
            scanForModelFiles()
        }
    }

    private fun hasAllFilesAccess(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.R || Environment.isExternalStorageManager()

    /** Scans for large model files other apps (e.g. AI Edge Gallery) left in shared storage. */
    private fun findModelOnDevice() {
        if (!hasAllFilesAccess()) {
            binding.txtStatus.text = getString(com.localai.assistant.R.string.find_model_need_permission)
            pendingFindModelScan = true
            val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION).apply {
                data = Uri.parse("package:$packageName")
            }
            startActivity(intent)
            return
        }
        scanForModelFiles()
    }

    private fun scanForModelFiles() {
        binding.txtStatus.text = "Searching for large model files…"
        lifecycleScope.launch {
            val result = ModelFileScanner.scan()
            val found = when (result) {
                is ModelFileScanner.ScanResult.NoPermission -> {
                    binding.txtStatus.text = getString(com.localai.assistant.R.string.find_model_need_permission)
                    return@launch
                }
                is ModelFileScanner.ScanResult.NothingFound -> {
                    binding.txtStatus.text = getString(
                        com.localai.assistant.R.string.find_model_none_found,
                        result.scannedDirs.joinToString(", ").ifBlank { "(no matching folders exist)" },
                    )
                    return@launch
                }
                is ModelFileScanner.ScanResult.Found -> result.files
            }
            AlertDialog.Builder(this@MainActivity)
                .setTitle(com.localai.assistant.R.string.dialog_find_model_title)
                .setItems(found.map { "${it.name} (${it.length() / (1024 * 1024)} MB)\n${it.absolutePath}" }.toTypedArray()) { _, index ->
                    loadModelFromPath(found[index].absolutePath)
                }
                .setNegativeButton(android.R.string.cancel, null)
                .show()
        }
    }

    private fun loadModelFromPath(path: String) {
        binding.txtStatus.text = "Loading model…"
        lifecycleScope.launch {
            val result = kotlin.runCatching {
                kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
                    AssistantApplication.from(this@MainActivity).engine.loadModelFromPath(path)
                }
            }
            binding.txtStatus.text = if (result.isSuccess) "Model loaded." else "Failed: ${result.exceptionOrNull()?.message}"
        }
    }

    private fun showDownloadModelDialog() {
        val padding = (16 * resources.displayMetrics.density).toInt()
        val urlInput = EditText(this).apply { hint = getString(com.localai.assistant.R.string.dialog_download_url_hint) }
        val tokenInput = EditText(this).apply { hint = getString(com.localai.assistant.R.string.dialog_download_token_hint) }
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(padding, padding, padding, padding)
            gravity = Gravity.CENTER_HORIZONTAL
            addView(urlInput)
            addView(tokenInput)
        }

        AlertDialog.Builder(this)
            .setTitle(com.localai.assistant.R.string.dialog_download_title)
            .setView(container)
            .setPositiveButton(com.localai.assistant.R.string.btn_download_model) { _, _ ->
                val url = urlInput.text.toString().trim()
                val token = tokenInput.text.toString().trim().ifBlank { null }
                if (url.isNotBlank()) downloadModel(url, token)
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
}
