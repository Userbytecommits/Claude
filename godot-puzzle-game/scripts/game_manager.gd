extends Node
class_name GameManager

var current_level = 1
var total_puzzles_solved = 0
var current_score = 0

@onready var ui = $CanvasLayer/UI
@onready var player = get_tree().root.get_node_or_null("Level1/Player")

static var instance: GameManager

func _ready():
	instance = self
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.puzzle_solved.connect(_on_puzzle_solved)

func _on_player_health_changed(health):
	if ui:
		ui.update_health(health)

func _on_puzzle_solved(count):
	total_puzzles_solved = count
	current_score += 100
	if ui:
		ui.update_score(current_score)

func level_complete():
	await get_tree().create_timer(1.0).timeout
	current_level += 1
	if current_level > 3:
		show_game_over_screen()
	else:
		get_tree().change_scene_to_file("res://scenes/levels/level_%d.tscn" % current_level)

func show_game_over_screen():
	var game_over_scene = preload("res://scenes/ui/game_over.tscn")
	get_tree().root.add_child(game_over_scene.instantiate())
