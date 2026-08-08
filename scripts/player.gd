class_name Player

extends CharacterBody2D

const NORMAL_SPEED: float = 96.0
const ACCELERATION: float = 80.0

var charge_progress: float = 0.0
const CHARGE_SPEED: float = 1.25
const CHARGE_POWER: float = 512.0

const MIN_BUBBLE_SPEED: float = 32.0

var health: int = 4

@export var blood_particles_scene: PackedScene
@export var spike_particles_scene: PackedScene

@onready var arrow_dist: float = $Arrow.position.x

var damage_timer: float = 0.0
const DAMAGE_TIMER_AMT: float = 0.75

var spike_uses: int = 0

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

func get_dir() -> Vector2:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var diff: Vector2 = mouse_pos - global_position
	return diff.normalized()

func _process(delta: float) -> void:
	$AnimatedSprite2D/Spike.visible = spike_uses > 0

	if health <= 0:
		hide()
		return
	else:
		show()

	rotate_to_mouse()
	
	var dir = get_dir()
	
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

	damage_timer = max(damage_timer - delta, 0.0)
	if damage_timer > 0.0:
		$AnimatedSprite2D.self_modulate = lerp(Color.WHITE, Color.RED, damage_timer / DAMAGE_TIMER_AMT)
	else:
		$AnimatedSprite2D.self_modulate = Color.WHITE
	
	update_enemy_arrow()

func _physics_process(delta: float) -> void:
	if health <= 0:
		velocity = Vector2.ZERO
		return

	move_and_slide()
	if velocity.length() > 8.0:
		velocity -= velocity.normalized() * delta * ACCELERATION
	else:
		velocity = Vector2.ZERO

func damage(amt: int) -> void:
	if health <= 0:
		return
	health -= amt
	damage_timer = DAMAGE_TIMER_AMT
	if health <= 0:
		var level: Node = get_node_or_null("/root/Main/Level")
		if level:
			var blood_particles: GPUParticles2D = blood_particles_scene.instantiate()
			blood_particles.global_position = global_position
			blood_particles.scale *= 0.4
			level.add_child(blood_particles)

func update_enemy_arrow() -> void:
	var level: Level = get_node_or_null("/root/Main/Level")
	if level == null:
		$Arrow.hide()
		return

	if level.get_enemies_left() == 0:
		$Arrow.hide()
		return

	var closest: Vector2 = Vector2.ZERO
	var first: bool = true
	for enemy: Node2D in level.get_node("Enemies").get_children():
		if first:
			closest = enemy.global_position
			first = false
			continue
		if (closest - global_position).length() > (enemy.global_position - global_position).length():
			closest = enemy.global_position
	
	if (closest - global_position).length() < 160.0:
		$Arrow.hide()
		return

	$Arrow.show()	
	var dir: Vector2 = (closest - global_position).normalized()
	$Arrow.position = dir * arrow_dist
	$Arrow.rotation = dir.angle()
