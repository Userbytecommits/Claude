extends CharacterBody2D
class_name Player

const SPEED = 220.0
const JUMP_FORCE = -440.0
const GRAVITY = 1100.0
const DASH_SPEED = 520.0
const DASH_DURATION = 0.16
const DASH_COOLDOWN = 0.5

var health = 3
var max_health = 3
var can_dash = true
var dash_direction = Vector2.ZERO
var dash_time = 0.0
var is_dashing = false
var is_on_ground = false
var puzzle_count = 0
var invulnerable = false
var facing = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var hurt_timer = $HurtTimer
@onready var dash_cooldown_timer = $DashCooldownTimer
@onready var camera = $Camera2D

signal health_changed(new_health)
signal puzzle_solved(count)
signal died

func _ready():
	add_to_group("player")
	hurt_timer.timeout.connect(_on_hurt_timer_timeout)
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)

func _physics_process(delta):
	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
	else:
		apply_gravity(delta)
		handle_movement()

	is_on_ground = is_on_floor()
	move_and_slide()
	update_animation()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func handle_movement():
	var input_dir = Input.get_axis("ui_left", "ui_right")

	if input_dir != 0:
		velocity.x = input_dir * SPEED
		facing = 1 if input_dir > 0 else -1
		sprite.flip_h = facing < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 2)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		AudioManager.play_sfx("jump")

	if Input.is_action_just_pressed("dash") and can_dash:
		perform_dash()

func update_animation():
	if is_dashing:
		sprite.play("jump")
	elif not is_on_ground:
		sprite.play("jump")
	elif abs(velocity.x) > 10:
		sprite.play("run")
	else:
		sprite.play("idle")

func perform_dash():
	is_dashing = true
	dash_time = DASH_DURATION
	can_dash = false

	var input_dir = Input.get_axis("ui_left", "ui_right")
	dash_direction = Vector2(input_dir, 0) if input_dir != 0 else Vector2(facing, 0)
	dash_direction = dash_direction.normalized()

	AudioManager.play_sfx("dash")
	dash_cooldown_timer.start(DASH_COOLDOWN)

func _on_dash_cooldown_timeout():
	can_dash = true

func take_damage(amount: int = 1):
	if invulnerable:
		return
	health -= amount
	health_changed.emit(health)
	AudioManager.play_sfx("damage")

	invulnerable = true
	hurt_timer.start()

	var mat = sprite.material
	if mat:
		mat.set_shader_parameter("damage_flash", 1.0)
		var tween = create_tween()
		tween.tween_method(func(v): mat.set_shader_parameter("damage_flash", v), 1.0, 0.0, hurt_timer.wait_time)

	if health <= 0:
		die()

func _on_hurt_timer_timeout():
	invulnerable = false

func die():
	died.emit()
	get_tree().reload_current_scene()

func solve_puzzle():
	puzzle_count += 1
	puzzle_solved.emit(puzzle_count)

func heal(amount: int = 1):
	health = min(health + amount, max_health)
	health_changed.emit(health)
