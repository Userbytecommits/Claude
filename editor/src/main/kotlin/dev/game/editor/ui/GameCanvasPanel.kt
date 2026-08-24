package dev.game.editor.ui

import javafx.scene.canvas.Canvas
import javafx.scene.input.MouseEvent
import javafx.scene.layout.StackPane
import javafx.scene.paint.Color
import dev.game.editor.project.GameProject

class GameCanvasPanel : StackPane() {
    private val canvas = Canvas(800.0, 600.0)
    private var currentProject: GameProject? = null
    private var selectedEntity: String? = null

    init {
        style = "-fx-border-color: #cccccc; -fx-border-width: 1;"
        children.add(canvas)

        canvas.setOnMouseClicked { event ->
            handleCanvasClick(event)
        }

        canvas.setOnMouseDragged { event ->
            handleCanvasDrag(event)
        }

        draw()
    }

    fun setProject(project: GameProject) {
        currentProject = project
        draw()
    }

    fun setContent(content: javafx.scene.layout.Pane) {
        children.clear()
        children.add(content)
    }

    private fun handleCanvasClick(event: MouseEvent) {
        println("Canvas clicked at: ${event.x}, ${event.y}")
        // TODO: Implement entity selection
    }

    private fun handleCanvasDrag(event: MouseEvent) {
        // TODO: Implement entity dragging
    }

    private fun draw() {
        val gc = canvas.graphicsContext2D

        gc.fill = Color.web("#222222")
        gc.fillRect(0.0, 0.0, canvas.width, canvas.height)

        // Draw grid
        gc.stroke = Color.web("#444444")
        gc.lineWidth = 0.5

        val gridSize = 32.0
        var x = 0.0
        while (x < canvas.width) {
            gc.strokeLine(x, 0.0, x, canvas.height)
            x += gridSize
        }

        var y = 0.0
        while (y < canvas.height) {
            gc.strokeLine(0.0, y, canvas.width, y)
            y += gridSize
        }

        // Draw placeholder entities if project is loaded
        currentProject?.let {
            gc.fill = Color.web("#FFD700")
            gc.fillOval(100.0, 100.0, 32.0, 32.0)

            gc.fill = Color.web("#8B4513")
            gc.fillRect(0.0, 500.0, canvas.width, 100.0)
        }
    }
}
