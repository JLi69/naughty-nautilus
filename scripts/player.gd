class_name Player

extends CharacterBody2D

const NORMAL_SPEED: float = 96.0
const ACCELERATION: float = 80.0

var charge_progress: float = 0.0
const CHARGE_SPEED: float = 1.25
const CHARGE_POWER: float = 512.0

const MIN_BUBBLE_SPEED: float = 32.0

func _ready() -> void:
	pass

func rotate_to_mouse() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var diff: Vector2 = mouse_pos - global_position
	$AnimatedSprite2D.rotation = diff.angle() + deg_to_rad(180.0)

	if abs(diff.angle()) < PI / 2:
		$AnimatedSprite2D.scale.y = -1.0
	else:
		$AnimatedSprite2D.scale.y = 1.0

func _process(delta: float) -> void:
	rotate_to_mouse()
	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var diff: Vector2 = mouse_pos - global_position
	var dir = diff.normalized()
	
	if Input.is_action_pressed("left_click"):
		if velocity.length() <= NORMAL_SPEED:
			velocity = dir * NORMAL_SPEED
	
	if Input.is_action_pressed("right_click"):
		if velocity.length() <= NORMAL_SPEED:
			charge_progress += (1.0 - charge_progress) * delta * CHARGE_SPEED
	else:
		velocity += dir * CHARGE_POWER * charge_progress
		charge_progress = 0.0
	
	if charge_progress > 0.0:
		$ChargeBar.show()
		$ChargeBar/Progress.size.x = $ChargeBar.size.x * charge_progress
	else:
		$ChargeBar.hide()
	
	$AnimatedSprite2D/Bubbles.emitting = velocity.length() > MIN_BUBBLE_SPEED

func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity -= velocity.normalized() * delta * ACCELERATION
