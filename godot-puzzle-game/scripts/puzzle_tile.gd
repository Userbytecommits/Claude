extends Node2D
class_name PuzzleTile

## A one-time pressure switch: touching it permanently opens its connected door.
## (A plate that re-closes the door on exit would strand the player mid-level,
## since reaching the door always requires leaving the plate first.)

var is_activated = false
var connected_door = null

const TEX_OFF = preload("res://assets/tiles/puzzle_tile.png")
const TEX_ON = preload("res://assets/tiles/puzzle_tile_active.png")

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

signal activated

func _ready():
	add_to_group("puzzles")
	sprite.texture = TEX_OFF
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = load("res://shaders/puzzle_tile.gdshader")
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		activate()

func activate():
	if is_activated:
		return
	is_activated = true
	sprite.texture = TEX_ON
	AudioManager.play_sfx("puzzle_activate")
	activated.emit()
	if connected_door:
		connected_door.open()
