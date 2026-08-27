extends CharacterBody2D
class_name Enemy

enum EnemyType { BLOB, SPIKE, FLYING }

@export var enemy_type: EnemyType = EnemyType.BLOB
@export var patrol_range = 100.0

const SPEED = 90.0
const GRAVITY = 1100.0

const FRAMES_BLOB = preload("res://assets/sprites/blob_frames.tres")
const FRAMES_SPIKE = preload("res://assets/sprites/spike_frames.tres")
const FRAMES_FLY = preload("res://assets/sprites/fly_frames.tres")

var health = 1
var direction = 1
var start_x = 0.0
var start_y = 0.0
var fly_time = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var damage_area = $DamageArea

signal died

func _ready():
	add_to_group("enemies")
	start_x = position.x
	start_y = position.y
	_apply_type_stats()
	damage_area.body_entered.connect(_on_damage_area_body_entered)

func _apply_type_stats():
	match enemy_type:
		EnemyType.BLOB:
			health = 1
			sprite.sprite_frames = FRAMES_BLOB
			sprite.play("move")
		EnemyType.SPIKE:
			health = 2
			sprite.sprite_frames = FRAMES_SPIKE
			sprite.play("idle")
		EnemyType.FLYING:
			health = 1
			sprite.sprite_frames = FRAMES_FLY
			sprite.play("move")

func _physics_process(delta):
	match enemy_type:
		EnemyType.BLOB:
			_move_patrol(delta, true)
		EnemyType.SPIKE:
			_move_patrol(delta, true, SPEED * 0.7)
		EnemyType.FLYING:
			_move_flying(delta)

func _move_patrol(delta, use_gravity: bool, speed: float = SPEED):
	if use_gravity and not is_on_floor():
		velocity.y += GRAVITY * delta
	elif use_gravity:
		velocity.y = 0

	velocity.x = direction * speed

	if abs(position.x - start_x) > patrol_range:
		direction *= -1
	sprite.flip_h = direction < 0

	move_and_slide()

func _move_flying(delta):
	fly_time += delta
	velocity.y = sin(fly_time * 2.0) * 60
	velocity.x = direction * SPEED

	if abs(position.x - start_x) > patrol_range:
		direction *= -1
	sprite.flip_h = direction < 0

	move_and_slide()

const STOMP_BOUNCE = -320.0

func take_damage(amount: int = 1):
	health -= amount
	var mat = sprite.material
	if mat:
		mat.set_shader_parameter("flash_amount", 1.0)
		var tween = create_tween()
		tween.tween_method(func(v): mat.set_shader_parameter("flash_amount", v), 1.0, 0.0, 0.15)
	if health <= 0:
		die()

func die():
	AudioManager.play_sfx("enemy_death")
	died.emit()
	queue_free()

func _on_damage_area_body_entered(body):
	if not body.is_in_group("player"):
		return
	# Hollow Knight style pogo: falling onto an enemy from above defeats it
	# and bounces the player up; touching it from the side/below hurts instead.
	var is_stomp = body.velocity.y > 0 and body.global_position.y < global_position.y - 8
	if is_stomp:
		take_damage(1)
		body.velocity.y = STOMP_BOUNCE
	else:
		body.take_damage(1)
