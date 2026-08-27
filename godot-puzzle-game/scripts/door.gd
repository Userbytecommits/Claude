extends StaticBody2D
class_name Door

var is_open = false
var closed_position = Vector2.ZERO
var open_offset = Vector2(0, -140)

const TEX = preload("res://assets/tiles/door.png")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	sprite.texture = TEX
	closed_position = position

func open():
	if is_open:
		return
	is_open = true
	collision.set_deferred("disabled", true)
	AudioManager.play_sfx("door_open")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", closed_position + open_offset, 0.4)
	tween.parallel().tween_property(sprite, "modulate:a", 0.35, 0.4)

func close():
	if not is_open:
		return
	is_open = false
	collision.set_deferred("disabled", false)
	var tween = create_tween()
	tween.tween_property(self, "position", closed_position, 0.3)
	tween.parallel().tween_property(sprite, "modulate:a", 1.0, 0.3)
