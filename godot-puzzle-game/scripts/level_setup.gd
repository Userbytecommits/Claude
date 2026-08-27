extends Node2D

@export var level_width: int = 2160
@export var ground_top_y: int = 852

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameManager.register_player(player)
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.limit_left = 0
			camera.limit_right = level_width
			camera.limit_top = -600
			camera.limit_bottom = ground_top_y + 200
			camera.make_current()

	var ui = get_node_or_null("UI")
	if ui:
		GameManager.register_ui(ui)

	setup_puzzle_doors()
	setup_goal()
	AudioManager.play_music("level_theme")

func setup_puzzle_doors():
	var puzzles = get_tree().get_nodes_in_group("puzzles")
	var doors = get_tree().get_nodes_in_group("doors")

	for i in range(min(puzzles.size(), doors.size())):
		var puzzle = puzzles[i]
		var door = doors[i]
		if puzzle and door:
			puzzle.connected_door = door

func setup_goal():
	var goal_area = get_node_or_null("GoalArea")
	if goal_area:
		goal_area.body_entered.connect(_on_goal_area_entered)

func _on_goal_area_entered(body):
	if body.is_in_group("player"):
		AudioManager.play_sfx("level_complete")
		GameManager.level_complete()
