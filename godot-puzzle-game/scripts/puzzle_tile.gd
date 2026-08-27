extends StaticBody2D
class_name PuzzleTile

enum PuzzleType { PRESSURE, SWITCH, SEQUENCE, MEMORY }

var puzzle_type: PuzzleType = PuzzleType.PRESSURE
var is_activated = false
var required_pressure_time = 0.5
var pressure_time = 0.0
var puzzle_id = 0
var connected_door = null
var glow_material = null

@onready var sprite = $Sprite2D
@onready var area = $Area2D

signal activated
signal deactivated

func _ready():
	glow_material = StandardMaterial3D.new()
	sprite.texture = ImageTexture.create_from_image(SpriteGenerator.create_tile_texture(32, 32, "puzzle"))
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = load("res://shaders/puzzle_tile.gdshader")

	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)

func _physics_process(delta):
	if puzzle_type == PuzzleType.PRESSURE:
		handle_pressure_puzzle(delta)

func _on_area_body_entered(body):
	if body is Player:
		if puzzle_type == PuzzleType.PRESSURE:
			pressure_time = 0.0

func _on_area_body_exited(body):
	if body is Player:
		pressure_time = 0.0
		if is_activated:
			is_activated = false
			deactivated.emit()

func handle_pressure_puzzle(delta):
	var bodies = area.get_overlapping_bodies()
	var has_player = bodies.any(func(b): return b is Player)

	if has_player:
		pressure_time += delta
		if pressure_time >= required_pressure_time and not is_activated:
			activate()
	else:
		pressure_time = 0.0

func activate():
	if not is_activated:
		is_activated = true
		modulate = Color.LIGHT_BLUE
		activated.emit()
		if connected_door:
			connected_door.open()

func deactivate():
	if is_activated:
		is_activated = false
		modulate = Color.WHITE
		deactivated.emit()
		if connected_door:
			connected_door.close()

func set_puzzle_type(type: PuzzleType):
	puzzle_type = type
