extends StaticBody2D
class_name Door

var is_open = false
var open_speed = 200.0
var open_position = Vector2.ZERO
var closed_position = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var animation = $AnimationPlayer

func _ready():
	closed_position = position
	open_position = position + Vector2(0, -50)
	sprite.texture = ImageTexture.create_from_image(SpriteGenerator.create_tile_texture(32, 64, "stone"))

func open():
	if not is_open:
		is_open = true
		collision.disabled = true
		var tween = create_tween()
		tween.tween_property(self, "position", open_position, 0.3)

func close():
	if is_open:
		is_open = false
		collision.disabled = false
		var tween = create_tween()
		tween.tween_property(self, "position", closed_position, 0.3)
