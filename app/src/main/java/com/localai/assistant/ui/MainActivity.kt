package com.localai.assistant.ui

import android.app.role.RoleManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
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
