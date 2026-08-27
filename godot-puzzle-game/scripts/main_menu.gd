extends Node2D

func _ready():
	var start_button = $CanvasLayer/VBoxContainer/StartButton
	var quit_button = $CanvasLayer/VBoxContainer/QuitButton

	start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn"))
	quit_button.pressed.connect(func(): get_tree().quit())
