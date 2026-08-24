package dev.game.editor.ui

import javafx.geometry.Insets
import javafx.scene.control.Label
import javafx.scene.control.ScrollPane
import javafx.scene.control.Separator
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import javafx.scene.paint.Color

class InspectorPanel : ScrollPane() {
    private val content = VBox(10.0).apply {
        padding = Insets(10.0)
        prefWidth = 300.0
    }

    init {
        this.content = content
        setFitToWidth(true)
        style = "-fx-border-color: #cccccc; -fx-border-width: 1 0 0 1;"

        showEmptyState()
    }

    fun showEmptyState() {
        content.children.clear()

        val label = Label("Select an entity to inspect").apply {
            style = "-fx-text-fill: #999999; -fx-font-size: 12px;"
        }

        content.children.add(label)
    }

    fun inspectEntity(entityName: String) {
        content.children.clear()

        Label(entityName).apply {
            style = "-fx-font-weight: bold; -fx-font-size: 14px;"
        }.let { content.children.add(it) }

        content.children.add(Separator())

        Label("Transform").apply {
            style = "-fx-font-weight: bold; -fx-font-size: 12px;"
        }.let { content.children.add(it) }

        // Position fields (placeholder)
        listOf("Position X:", "Position Y:", "Rotation:", "Scale X:", "Scale Y:").forEach { label ->
            Label(label).apply {
                style = "-fx-font-size: 11px;"
            }.let { content.children.add(it) }
        }

        content.children.add(Separator())

        Label("Components").apply {
            style = "-fx-font-weight: bold; -fx-font-size: 12px;"
        }.let { content.children.add(it) }

        // Component list (placeholder)
        listOf("SpriteComponent", "RigidbodyComponent", "BoxColliderComponent").forEach { comp ->
            Label("  ✓ $comp").apply {
                style = "-fx-font-size: 11px;"
            }.let { content.children.add(it) }
        }

        VBox().apply {
            VBox.setVgrow(this, Priority.ALWAYS)
        }.let { content.children.add(it) }
    }
}
