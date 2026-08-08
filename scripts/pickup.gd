class_name Pickup

extends Area2D

@onready var default_scale: Vector2 = scale

@export var bubble_particle_scene: PackedScene

var animation_time: float = 0.0

var delay: float = 0.75

var add_bubbles: bool = true

static var pickup_table: Array[String] = [
	"health",
	"health",
	"health",
	"speed",
	"speed",
	"spike",
	"spike",
	"spike",
]
@export var type: String = "" # For debug purposes only

func _ready() -> void:
	rotation = randf_range(0.0, 2.0 * PI)

	var level: Level = get_node_or_null("/root/Main/Level")
	if level and add_bubbles:
		var bubble_particles: GPUParticles2D = bubble_particle_scene.instantiate()
		bubble_particles.global_position = global_position
		level.call_deferred("add_child", bubble_particles)
	
	if type.is_empty():
		$AnimatedSprite2D.animation = pickup_table[randi() % pickup_table.size()]
	else:
		$AnimatedSprite2D.animation = type

func _process(delta: float) -> void:
	delay = max(delay - delta, 0.0)
	animation_time += delta
	var sprite_scale = lerpf(0.8, 1.2, (sin(animation_time * 4.0) + 1.0) / 2.0)
	scale = sprite_scale * default_scale

func apply_pickup() -> void:
	var player: Player = $/root/Main/Player
	match $AnimatedSprite2D.animation:
		"health":
			player.health += 1
		"speed":
			player.velocity += player.get_dir() * Player.CHARGE_POWER * 1.5
		"spike":
			player.spike_uses = 12
		_:
			pass

func _on_area_entered(area: Area2D) -> void:
	if delay > 0.0:
		return

	var player: Player = $/root/Main/Player
	if $AnimatedSprite2D.animation == "spike" and player.spike_uses > 0:
		return

	if area.is_in_group("player_hit") or area.is_in_group("shell"):
		queue_free()
		apply_pickup()
		var level: Level = get_node_or_null("/root/Main/Level")
		if level:
			var bubble_particles: GPUParticles2D = bubble_particle_scene.instantiate()
			bubble_particles.global_position = global_position
			level.call_deferred("add_child", bubble_particles)

