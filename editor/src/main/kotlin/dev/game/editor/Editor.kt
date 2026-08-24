package dev.game.editor

import javafx.application.Application
import javafx.stage.Stage
import dev.game.editor.ui.EditorWindow

fun main() {
    Application.launch(Editor::class.java)
}

class Editor : Application() {
    override fun start(primaryStage: Stage) {
        val editorWindow = EditorWindow(primaryStage)
        editorWindow.show()
    }
}
