extends CanvasLayer

@onready var score_label = $VBoxContainer/Score
@onready var restart_button = $VBoxContainer/RestartButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	score_label.text = "Final Score: %d" % GameManager.current_score
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_restart_pressed():
	GameManager.current_level = 1
	GameManager.current_score = 0
	GameManager.total_puzzles_solved = 0
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
	queue_free()

func _on_quit_pressed():
	get_tree().quit()
