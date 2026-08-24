package dev.game.editor.ui

import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.Scene
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.Menu
import javafx.scene.control.MenuBar
import javafx.scene.control.MenuItem
import javafx.scene.control.SeparatorMenuItem
import javafx.scene.control.TreeItem
import javafx.scene.control.TreeView
import javafx.scene.layout.BorderPane
import javafx.scene.layout.HBox
import javafx.scene.layout.Priority
import javafx.scene.layout.VBox
import javafx.stage.Stage
import dev.game.editor.project.GameProject
import java.io.File

class EditorWindow(private val primaryStage: Stage) {
    private val root = BorderPane()
    private var currentProject: GameProject? = null

    private val sceneTreeView = TreeView<String>()
    private val gameCanvasPanel = GameCanvasPanel()
    private val inspectorPanel = InspectorPanel()

    fun show() {
        primaryStage.title = "Android Game Engine Editor"
        primaryStage.width = 1400.0
        primaryStage.height = 900.0

        setupMenuBar()
        setupLayout()

        val scene = Scene(root)
        primaryStage.scene = scene
        primaryStage.show()

        showWelcomeScreen()
    }

    private fun setupMenuBar() {
        val menuBar = MenuBar()

        val fileMenu = Menu("File").apply {
            items.addAll(
                MenuItem("New Project").apply {
                    setOnAction { createNewProject() }
                },
                MenuItem("Open Project").apply {
                    setOnAction { openProject() }
                },
                SeparatorMenuItem(),
                MenuItem("Save").apply {
                    setOnAction { saveProject() }
                },
                SeparatorMenuItem(),
                MenuItem("Exit").apply {
                    setOnAction { primaryStage.close() }
                }
            )
        }

        val editMenu = Menu("Edit").apply {
            items.addAll(
                MenuItem("Undo").apply { isDisable = true },
                MenuItem("Redo").apply { isDisable = true }
            )
        }

        val viewMenu = Menu("View").apply {
            items.addAll(
                MenuItem("Reset Layout").apply { isDisable = true }
            )
        }

        val toolsMenu = Menu("Tools").apply {
            items.addAll(
                MenuItem("Export to APK").apply {
                    setOnAction { exportToAPK() }
                }
            )
        }

        val helpMenu = Menu("Help").apply {
            items.addAll(
                MenuItem("Documentation").apply { isDisable = true },
                MenuItem("About").apply {
                    setOnAction { showAbout() }
                }
            )
        }

        menuBar.menus.addAll(fileMenu, editMenu, viewMenu, toolsMenu, helpMenu)
        root.top = menuBar
    }

    private fun setupLayout() {
        val centerPane = HBox(10.0).apply {
            padding = Insets(10.0)

            gameCanvasPanel.apply {
                HBox.setHgrow(this, Priority.ALWAYS)
                prefWidth = 800.0
            }
            children.add(gameCanvasPanel)

            inspectorPanel.apply {
                prefWidth = 300.0
            }
            children.add(inspectorPanel)
        }

        val leftPanel = VBox(10.0).apply {
            padding = Insets(10.0)
            prefWidth = 200.0

            Label("Scene Hierarchy:").apply {
                style = "-fx-font-weight: bold;"
            }.let { children.add(it) }

            sceneTreeView.apply {
                VBox.setVgrow(this, Priority.ALWAYS)
            }.let { children.add(it) }

            HBox(5.0).apply {
                alignment = Pos.CENTER
                Button("+ Add Entity").apply {
                    setOnAction { addEntity() }
                }.let { children.add(it) }
            }.let { children.add(it) }
        }

        val mainPane = HBox(10.0).apply {
            padding = Insets(10.0)
            children.addAll(leftPanel, centerPane)
            HBox.setHgrow(centerPane, Priority.ALWAYS)
        }

        root.center = mainPane
    }

    private fun showWelcomeScreen() {
        val welcomeBox = VBox(20.0).apply {
            alignment = Pos.CENTER
            padding = Insets(40.0)

            Label("Welcome to Android Game Engine Editor").apply {
                style = "-fx-font-size: 24px; -fx-font-weight: bold;"
            }.let { children.add(it) }

            Label("Create amazing 2D games for Android").apply {
                style = "-fx-font-size: 14px;"
            }.let { children.add(it) }

            HBox(10.0).apply {
                alignment = Pos.CENTER
                Button("New Project").apply {
                    style = "-fx-font-size: 14px; -fx-padding: 10px 30px;"
                    setOnAction { createNewProject() }
                }.let { children.add(it) }

                Button("Open Project").apply {
                    style = "-fx-font-size: 14px; -fx-padding: 10px 30px;"
                    setOnAction { openProject() }
                }.let { children.add(it) }
            }.let { children.add(it) }
        }

        gameCanvasPanel.setContent(welcomeBox)
    }

    private fun createNewProject() {
        val projectName = "My Game"
        val projectPackage = "com.example.mygame"
        val projectDir = File(System.getProperty("user.home"), ".game-engine/$projectName")

        currentProject = GameProject(projectName, projectPackage, projectDir).apply {
            initializeDirectories()
            createScene("Main")
            save()
        }

        loadProject()
    }

    private fun openProject() {
        // TODO: Implement file chooser
    }

    private fun saveProject() {
        currentProject?.save()
    }

    private fun exportToAPK() {
        // TODO: Show export dialog
    }

    private fun loadProject() {
        currentProject?.let { project ->
            primaryStage.title = "Android Game Engine Editor - ${project.name}"

            // Update scene tree
            val rootItem = TreeItem("${project.name} (Scenes)").apply {
                isExpanded = true
            }

            val mainSceneItem = TreeItem("Main (Scene)").apply {
                isExpanded = true
            }
            rootItem.children.add(mainSceneItem)

            sceneTreeView.root = rootItem

            gameCanvasPanel.setProject(project)
        }
    }

    private fun addEntity() {
        // TODO: Show entity creation dialog
    }

    private fun showAbout() {
        println("Android Game Engine Editor v1.0")
    }
}
