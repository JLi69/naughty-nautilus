class_name Fish

extends CharacterBody2D

@onready var main: Main = $/root/Main

@export var speed: float = 80.0
# In degrees per second
@export var rotation_speed: float = 60.0

@export var max_health: float = 5.0
@onready var health: float = max_health

@export var damage: int = 1
@export var blood_particles_scene: PackedScene
@export var blood_particles_scale: float = 0.3

@onready var speed_scale: float = randf_range(0.8, 1.2)
@onready var level: Node2D = $/root/Main/Level

var knock_back: Vector2 = Vector2.ZERO
var damage_timer: float = 0.0
const DAMAGE_COOLDOWN: float = 0.75

var spawn_delay: float = 0.4 

var can_attack_player: bool = false
var attack_timer: float = 0.0
@export var attack_cooldown: float = 1.0

@export var drop_chance: float = 0.05
@export var pickup_scene: PackedScene

func _ready() -> void:
	var player: Player = $/root/Main/Player
	var diff: Vector2 = (player.global_position - global_position).normalized()
	rotation = diff.angle()
	if abs(rotation) < PI / 2:
		$AnimatedSprite2D.scale.y = 1.0
	else:
		$AnimatedSprite2D.scale.y = -1.0
	if spawn_delay > 0.0:
		hide()

func _process(delta: float) -> void:
	if health <= 0.0:
		var blood_particles: GPUParticles2D = blood_particles_scene.instantiate()
		blood_particles.global_position = global_position
		blood_particles.scale *= blood_particles_scale
		level.add_child(blood_particles)
		queue_free()

		if randf() < drop_chance:
			var pickup: Pickup = pickup_scene.instantiate()
			pickup.add_bubbles = false
			pickup.global_position = global_position
			level.add_child(pickup)
		return

	$Healthbar.set_health(health, max_health)

	if spawn_delay > 0.0:
		hide()
		spawn_delay -= delta
		if spawn_delay <= 0.0:
			show()
		return
	
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
	if dir1.dot(diff) > dir2.dot(diff) and dir.dot(diff) < 0.99:
		rotation += angle_diff
	elif dir1.dot(diff) < dir2.dot(diff) and dir.dot(diff) < 0.99:
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

static func calculate_damage(player_speed: float, min_speed: float) -> float:
	return max((player_speed - min_speed) / 96.0, 0.0)

func _on_hit_detector_area_entered(area: Area2D) -> void:
	if spawn_delay > 0.0:
		return

	var parent: Node = area.get_parent()
	if area.is_in_group("shell") and damage_timer <= 0.0:
		if parent is Player:
			var player_speed: float = parent.velocity.length()
			health -= calculate_damage(player_speed, Player.NORMAL_SPEED * 1.25)
			var diff: Vector2 = (parent.global_position - global_position).normalized()
			knock_back = -diff * max(player_speed * 1.25, 64.0)
			if calculate_damage(player_speed, Player.NORMAL_SPEED * 1.25) > 0.0:
				damage_timer = DAMAGE_COOLDOWN
	elif area.is_in_group("spike") and damage_timer <= 0.0:
		var player: Player = $/root/Main/Player
		if player.spike_uses <= 0:
			return
		player.spike_uses = max(player.spike_uses - 1, 0)
		if player.spike_uses <= 0 and player.health > 0:
			var spike_particles: GPUParticles2D = player.spike_particles_scene.instantiate()
			spike_particles.global_position = player.get_node("AnimatedSprite2D/Spike").global_position
			level.add_child(spike_particles)
		health -= calculate_damage(player.velocity.length(), Player.NORMAL_SPEED * 0.75) * 6.0
		if calculate_damage(player.velocity.length(), Player.NORMAL_SPEED * 0.75) > 0.0:
			damage_timer = DAMAGE_COOLDOWN

func _on_damage_zone_area_entered(area: Area2D) -> void:
	if spawn_delay > 0.0:
		return

	if area.is_in_group("player_hit"):
		can_attack_player = true
		attack_timer = 0.0

func _on_damage_zone_area_exited(area: Area2D) -> void:
	if spawn_delay > 0.0:
		return

	if area.is_in_group("player_hit"):
		can_attack_player = false
