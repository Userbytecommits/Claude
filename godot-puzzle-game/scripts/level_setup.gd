extends Node2D
class_name LevelSetup

func _ready():
	setup_puzzle_doors()
	setup_enemies()
	setup_goal()

func setup_puzzle_doors():
	var puzzles = get_tree().get_nodes_in_group("puzzles")
	var doors = get_tree().get_nodes_in_group("doors")

	for i in range(min(puzzles.size(), doors.size())):
		var puzzle = puzzles[i]
		var door = doors[i]
		if puzzle and door:
			puzzle.connected_door = door
			puzzle.activated.connect(func(): door.open())
			puzzle.deactivated.connect(func(): door.close())

func setup_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy:
			enemy.add_to_group("enemies")

func setup_goal():
	var goal_area = get_node_or_null("GoalArea")
	if goal_area:
		goal_area.area_entered.connect(_on_goal_area_entered)

func _on_goal_area_entered(area):
	if area.is_in_group("player"):
		GameManager.level_complete()
