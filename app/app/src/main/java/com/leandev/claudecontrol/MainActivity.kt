package com.leandev.claudecontrol

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val apiKeyInput = findViewById<EditText>(R.id.apiKeyInput)
        val goalInput = findViewById<EditText>(R.id.goalInput)
        val workspaceIdInput = findViewById<EditText>(R.id.workspaceIdInput)
        val logView = findViewById<TextView>(R.id.logView)

        apiKeyInput.setText(AppState.loadApiKey(this))
        goalInput.setText(AppState.loadGoal(this))
        workspaceIdInput.setText(AppState.loadWorkspaceId(this))

        AppState.logCallback = { msg ->
            runOnUiThread {
                logView.append("$msg\n")
            }
        }

        findViewById<Button>(R.id.saveButton).setOnClickListener {
            AppState.save(this, apiKeyInput.text.toString().trim(), goalInput.text.toString().trim(), workspaceIdInput.text.toString().trim())
            AppState.log("Gespeichert.")
        }

        findViewById<Button>(R.id.openAccessibilitySettings).setOnClickListener {
            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
        }

        findViewById<Button>(R.id.stepButton).setOnClickListener {
            AppState.save(this, apiKeyInput.text.toString().trim(), goalInput.text.toString().trim(), workspaceIdInput.text.toString().trim())
            val service = AppState.serviceInstance
            if (service == null) {
                AppState.log("Fehler: Bedienungshilfen-Dienst nicht aktiv.")
            } else {
                service.runStep()
            }
        }

        val autoButton = findViewById<Button>(R.id.autoButton)
        var running = false
        autoButton.setOnClickListener {
            AppState.save(this, apiKeyInput.text.toString().trim(), goalInput.text.toString().trim(), workspaceIdInput.text.toString().trim())
            val service = AppState.serviceInstance
            if (service == null) {
                AppState.log("Fehler: Bedienungshilfen-Dienst nicht aktiv.")
                return@setOnClickListener
            }
            running = !running
            if (running) {
                autoButton.text = "Auto-Loop stoppen"
                service.runAutoLoop()
            } else {
                autoButton.text = "Auto-Loop starten"
                service.stopAuto()
            }
        }
    }
}
