class_name Fish

extends CharacterBody2D

@onready var main: Main = $/root/Main

@export var speed: float = 80.0
# In degrees per second
@export var rotation_speed: float = 60.0

@export var max_health: float = 4.0
@onready var health: float = max_health

@export var damage: int = 1
@export var blood_particles_scene: PackedScene
@export var blood_particles_scale: float = 0.3

@onready var speed_scale: float = randf_range(0.8, 1.2)
@onready var level: Node2D = $/root/Main/Level

var knock_back: Vector2 = Vector2.ZERO
var damage_timer: float = 0.0
const DAMAGE_COOLDOWN: float = 0.75

var can_attack_player: bool = false
var attack_timer: float = 0.0
@export var attack_cooldown: float = 1.0

func _ready() -> void:
	var player: Player = $/root/Main/Player
	var diff: Vector2 = (player.global_position - global_position).normalized()
	rotation = diff.angle()
	if abs(rotation) < PI / 2:
		$AnimatedSprite2D.scale.y = 1.0
	else:
		$AnimatedSprite2D.scale.y = -1.0

func _process(delta: float) -> void:
	if health <= 0.0:
		var blood_particles: GPUParticles2D = blood_particles_scene.instantiate()
		blood_particles.global_position = global_position
		blood_particles.scale *= blood_particles_scale
		level.add_child(blood_particles)
		queue_free()
		return

	$Healthbar.set_health(health, max_health)
	
	if damage_timer <= 0.0:
		knock_back -= knock_back.normalized() * min(knock_back.length(), 80.0) * delta

	if damage_timer >= 0.0:
		damage_timer -= delta
	if damage_timer > 0.0:
		$AnimatedSprite2D.self_modulate = lerp(Color.WHITE, Color.RED, damage_timer / DAMAGE_COOLDOWN)
	else:
		$AnimatedSprite2D.self_modulate = Color.WHITE

	var dir: Vector2 = Vector2(cos(rotation), sin(rotation))
	velocity = speed * speed_scale * dir + knock_back

	# Update rotation
	var diff: Vector2 = (main.player.global_position - global_position).normalized()
	var angle_diff: float = delta * deg_to_rad(rotation_speed)
	var dir1: Vector2 = Vector2(cos(rotation + angle_diff), sin(rotation + angle_diff))
	var dir2: Vector2 = Vector2(cos(rotation - angle_diff), sin(rotation - angle_diff))
	if dir1.dot(diff) > dir2.dot(diff):
		rotation += angle_diff
	elif dir1.dot(diff) < dir2.dot(diff):
		rotation -= angle_diff

	if abs(rotation) < PI / 2:
		$AnimatedSprite2D.scale.y = 1.0
	else:
		$AnimatedSprite2D.scale.y = -1.0	

	if can_attack_player and damage_timer <= 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			main.player.damage(damage)

func _physics_process(delta: float) -> void:
	var prev_pos: Vector2 = global_position
	move_and_slide()
	var current_pos: Vector2 = global_position
	var current_speed: float = (current_pos - prev_pos).length() / delta

	if current_speed <= 64.0:
		knock_back = Vector2.ZERO

static func calculate_damage(player_speed: float) -> float:
	return max((player_speed - Player.NORMAL_SPEED * 1.25) / 96.0, 0.0)

func _on_hit_detector_area_entered(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if area.is_in_group("shell") and damage_timer <= 0.0:
		if parent is Player:
			var player_speed: float = parent.velocity.length()
			health -= calculate_damage(player_speed)
			var diff: Vector2 = (parent.global_position - global_position).normalized()
			knock_back = -diff * max(player_speed * 1.25, 64.0)
			damage_timer = DAMAGE_COOLDOWN

func _on_damage_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hit"):
		can_attack_player = true
		attack_timer = 0.0

func _on_damage_zone_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hit"):
		can_attack_player = false
