extends CanvasLayer
class_name GameUI

const HEART_FULL = preload("res://assets/ui/heart_full.png")
const HEART_EMPTY = preload("res://assets/ui/heart_empty.png")

var max_hearts = 3
var heart_icons: Array[TextureRect] = []

@onready var hearts_box = $Margin/TopRow/HeartsBox
@onready var score_label = $Margin/TopRow/ScoreBox/ScoreLabel
@onready var puzzle_label = $Margin/TopRow/PuzzleBox/PuzzleLabel

func _ready():
	for child in hearts_box.get_children():
		if child is TextureRect:
			heart_icons.append(child)

func update_health(health: int):
	for i in range(heart_icons.size()):
		heart_icons[i].texture = HEART_FULL if i < health else HEART_EMPTY

func update_score(score: int):
	score_label.text = str(score)

func update_puzzles(count: int):
	puzzle_label.text = str(count)
