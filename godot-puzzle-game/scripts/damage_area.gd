extends Area2D
class_name DamageArea

var damage_amount = 1
var can_damage = true
var damage_cooldown = 1.0

@onready var cooldown_timer = Timer.new()

func _ready():
	add_child(cooldown_timer)
	cooldown_timer.wait_time = damage_cooldown
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player and can_damage:
		body.take_damage(damage_amount)
		can_damage = false
		cooldown_timer.start()

func _on_cooldown_timeout():
	can_damage = true
