extends CanvasLayer
class_name GameUI

@onready var health_label = Label.new()
@onready var score_label = Label.new()
@onready var puzzle_label = Label.new()

func _ready():
	setup_ui()

func setup_ui():
	# Health Label
	health_label.text = "HP: 3/3"
	health_label.add_theme_font_size_override("font_size", 32)
	add_child(health_label)
	health_label.position = Vector2(20, 20)

	# Score Label
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 28)
	add_child(score_label)
	score_label.position = Vector2(20, 70)

	# Puzzle Label
	puzzle_label.text = "Puzzles: 0"
	puzzle_label.add_theme_font_size_override("font_size", 28)
	add_child(puzzle_label)
	puzzle_label.position = Vector2(20, 120)

func update_health(health: int):
	health_label.text = "HP: %d/3" % health

func update_score(score: int):
	score_label.text = "Score: %d" % score

func update_puzzles(count: int):
	puzzle_label.text = "Puzzles: %d" % count
