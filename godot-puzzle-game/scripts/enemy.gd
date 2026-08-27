extends CharacterBody2D
class_name Enemy

enum EnemyType { BLOB, SPIKE, FLYING }

const SPEED = 100.0
const GRAVITY = 980.0

var enemy_type: EnemyType = EnemyType.BLOB
var health = 1
var direction = 1
var can_attack = true
var patrol_range = 100.0
var start_x = 0.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var attack_timer = $AttackTimer

signal died

func _ready():
	start_x = position.x
	set_enemy_type(enemy_type)

func set_enemy_type(type: EnemyType):
	enemy_type = type
	match type:
		EnemyType.BLOB:
			health = 1
			sprite.texture = ImageTexture.create_from_image(SpriteGenerator.create_enemy_texture(32, 32, "blob"))
		EnemyType.SPIKE:
			health = 2
			sprite.texture = ImageTexture.create_from_image(SpriteGenerator.create_enemy_texture(32, 32, "spike"))
		EnemyType.FLYING:
			health = 1
			sprite.texture = ImageTexture.create_from_image(SpriteGenerator.create_enemy_texture(32, 32, "blob"))

func _physics_process(delta):
	match enemy_type:
		EnemyType.BLOB:
			handle_blob(delta)
		EnemyType.SPIKE:
			handle_spike(delta)
		EnemyType.FLYING:
			handle_flying(delta)

func handle_blob(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	velocity.x = direction * SPEED

	if abs(position.x - start_x) > patrol_range:
		direction *= -1
		sprite.flip_h = direction < 0

	velocity = move_and_slide()

func handle_spike(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	velocity.x = direction * SPEED * 0.8

	if abs(position.x - start_x) > patrol_range:
		direction *= -1
		sprite.flip_h = direction < 0

	velocity = move_and_slide()

func handle_flying(delta):
	velocity.y = sin(position.x * 0.02 + get_physics_process_delta_time()) * 50
	velocity.x = direction * SPEED

	if abs(position.x - start_x) > patrol_range:
		direction *= -1
		sprite.flip_h = direction < 0

	velocity = move_and_slide()

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		die()

func die():
	died.emit()
	queue_free()

func _on_attack_timer_timeout():
	can_attack = true
