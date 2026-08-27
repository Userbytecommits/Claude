extends CharacterBody2D
class_name Player

const SPEED = 200.0
const JUMP_FORCE = -400.0
const GRAVITY = 980.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.15

var health = 3
var max_health = 3
var can_dash = true
var dash_direction = Vector2.ZERO
var dash_time = 0.0
var is_dashing = false
var is_on_ground = false
var puzzle_count = 0

@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var collision = $CollisionShape2D
@onready var hurt_timer = $HurtTimer

signal health_changed(new_health)
signal puzzle_solved(count)

func _ready():
	if sprite:
		sprite.texture = ImageTexture.create_from_image(SpriteGenerator.create_player_texture())

func _physics_process(delta):
	apply_gravity(delta)
	handle_input()

	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
	else:
		handle_movement()

	is_on_ground = is_on_floor()
	velocity = move_and_slide()

func apply_gravity(delta):
	if not is_on_floor() and not is_dashing:
		velocity.y += GRAVITY * delta

func handle_movement():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_dir.x != 0:
		velocity.x = input_dir.x * SPEED
		if sprite:
			sprite.flip_h = input_dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and is_on_ground:
		velocity.y = JUMP_FORCE

func handle_input():
	if Input.is_action_just_pressed("ui_up") and can_dash and not is_on_ground:
		perform_dash()

func perform_dash():
	is_dashing = true
	dash_time = DASH_DURATION
	can_dash = false
	dash_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dash_direction.length() == 0:
		dash_direction = Vector2(1, 0) if not sprite.flip_h else Vector2(-1, 0)

	await get_tree().create_timer(DASH_DURATION + 0.1).timeout
	can_dash = true

func take_damage(amount: int = 1):
	health -= amount
	health_changed.emit(health)

	if hurt_timer:
		hurt_timer.start()

	if health <= 0:
		die()

func die():
	get_tree().reload_current_scene()

func solve_puzzle():
	puzzle_count += 1
	puzzle_solved.emit(puzzle_count)

func heal(amount: int = 1):
	health = min(health + amount, max_health)
	health_changed.emit(health)

func reset_dash():
	can_dash = true
