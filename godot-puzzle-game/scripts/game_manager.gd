extends Node

var current_level = 1
var total_puzzles_solved = 0
var current_score = 0

var player = null
var ui = null

func register_player(p) -> void:
	player = p
	if not p.health_changed.is_connected(_on_player_health_changed):
		p.health_changed.connect(_on_player_health_changed)
	if not p.puzzle_solved.is_connected(_on_puzzle_solved):
		p.puzzle_solved.connect(_on_puzzle_solved)
	if ui:
		ui.update_health(p.health)

func register_ui(u) -> void:
	ui = u
	if player:
		ui.update_health(player.health)
	ui.update_score(current_score)
	ui.update_puzzles(total_puzzles_solved)

func _on_player_health_changed(health):
	if ui:
		ui.update_health(health)

func _on_puzzle_solved(count):
	total_puzzles_solved = count
	current_score += 100
	if ui:
		ui.update_score(current_score)
		ui.update_puzzles(count)

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

func reset():
	current_level = 1
	current_score = 0
	total_puzzles_solved = 0
	player = null
	ui = null
