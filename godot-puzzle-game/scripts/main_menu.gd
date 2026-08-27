extends Node2D

func _ready():
	var start_button = $CanvasLayer/VBoxContainer/StartButton
	var quit_button = $CanvasLayer/VBoxContainer/QuitButton

	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(func(): get_tree().quit())

	AudioManager.play_music("menu_theme")

func _on_start_pressed():
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
