class_name Level

extends Node2D

var wave: int = 0
const WAVE_COUNTDOWN_TIME: float = 5.0
var wave_countdown: float = 0.0

var wave_queue: Array = []

var spawn_timer: float = 0.0
var spawn_pickup_timer: float = 20.0

@onready var tile_size: float = $Walls.tile_set.tile_size.x
@onready var player: Player = $/root/Main/Player

@export var bubble_particles_scene: PackedScene
@export var pickup_scene: PackedScene

static var enemy_scenes: Dictionary = {
	"fish" : preload("uid://btnoj88sbgiww"),
	"small_fish" : preload("uid://dopsw1ex0a78b"),
	"big_fish" : preload("uid://dioh7lgmurx02"),
	"jellyfish" : preload("uid://djfmekum1n7qa"),
}

var weights: Array[String] = [ "fish" ]

@onready var children = get_children()

func get_enemies_left() -> int:
	return $Enemies.get_child_count()

static func get_count_range(current_wave: int) -> Array[int]:
	match current_wave:
		0, 1:
			return [ 2, 3 ]
		2, 3:
			return [ 2, 4 ]
		4, 5, 6:
			return [ 3, 5 ]
		7, 8, 9:
			return [ 4, 6 ]
		10, 11, 12:
			return [ 4, 8 ]
		_:
			return [ 5, 10 ]

static func get_enemies(current_wave: int, enemy_weights: Array[String]) -> Array:
	var enemies = []

	var count_range = get_count_range(current_wave)
	var count = randi_range(count_range[0], count_range[1])

	for i in range(count):
		enemies.push_back(enemy_weights[randi() % enemy_weights.size()])

	return enemies

func prepare_wave() -> void:
	wave += 1
	
	match wave:
		3:
			weights += [ "fish", "jellyfish" ]
		4:
			weights += [ "fish", "small_fish" ]
		7:
			weights += [ "small_fish", "jellyfish" ]
		8:
			weights += [ "fish", "fish", "fish", "small_fish", "jellyfish", "big_fish" ]
		11:
			weights += [ "big_fish" ]
		_:
			pass

	wave_countdown = WAVE_COUNTDOWN_TIME
	spawn_timer = randf_range(10.0, 15.0)

	var spawn_counts: int = ceili(float(wave) / 2.0)
	for i in range(spawn_counts):
		wave_queue.push_back(get_enemies(wave, weights))

	if wave == 7:
		wave_queue.push_front([ "big_fish" ])
	elif wave % 4 == 0 and wave > 8:
		var count: int = min(int(float(wave - 4) / 4.0), 4)
		for i in range(count):
			wave_queue[0].push_back("big_fish")

# Returns true upon success, false otherwise
func try_spawning(
	scene: PackedScene,
	center_pos: Vector2,
	min_dist: float,
	max_dist: float,
	parent: Node,
	check_radius: int = 0,
	add_bubbles: bool = true,
	bubble_scale: float = 1.0
) -> bool:
	var dist: float = randf_range(min_dist, max_dist) * tile_size
	var angle: float = randf_range(0.0, 2.0 * PI)
	var pos: Vector2 = dist * Vector2(cos(angle), sin(angle)) + center_pos
	pos.x = tile_size * floor(pos.x / tile_size) + tile_size / 2.0
	pos.y = tile_size * floor(pos.y / tile_size) + tile_size / 2.0
	
	var tile_pos: Vector2i = Vector2i(floori(pos.x / tile_size), floori(pos.y / tile_size))
	if $Walls.get_cell_tile_data(tile_pos):
		return false
	for dx in range(-check_radius, check_radius + 1):
		for dy in range(-check_radius, check_radius + 1):
			var diff: Vector2i = Vector2i(dx, dy)
			if $Walls.get_cell_tile_data(tile_pos + diff):
				return false

	var node: Node2D = scene.instantiate()
	node.global_position = pos
	parent.add_child(node)

	if add_bubbles:
		var bubbles: GPUParticles2D = bubble_particles_scene.instantiate()
		bubbles.scale *= bubble_scale
		bubbles.global_position = node.global_position
		Sfx.play_at(self, bubbles.global_position, "bubbles")
		add_child(bubbles)

	return true

func spawn() -> void:
	if get_enemies_left() > 0 and spawn_timer >= 0.0:
		return

	if wave_queue.is_empty():
		return

	while get_enemies_left() <= 0:
		for enemy_id: String in wave_queue[wave_queue.size() - 1]:
			var check_radius: int = 0
			var bubble_scale: float = 1.0
			if enemy_id == "big_fish":
				check_radius = 1
				bubble_scale = 2.0
			var enemy_scene = enemy_scenes[enemy_id]
			for i in range(4):
				if try_spawning(enemy_scene, player.global_position, 10.0, 15.0, $Enemies, check_radius, true, bubble_scale):
					break
	wave_queue.pop_back()

func spawn_pickups(delta: float) -> void:
	spawn_pickup_timer -= delta
	if spawn_pickup_timer > 0.0:
		return
	spawn_pickup_timer = randf_range(30.0, 45.0)

	var count = randi_range(1, 2)
	for i in range(count):
		for try_num in range(2):
			if try_spawning(pickup_scene, player.global_position, 7.0, 20.0, self, 0, false):
				break

func _process(delta: float) -> void:
	if player.health <= 0:
		wave_countdown = 0.0
		return

	spawn_pickups(delta)

	if get_enemies_left() == 0 and wave_queue.is_empty():
		prepare_wave()

	if wave_countdown > 0.0:
		wave_countdown -= delta
		return

	# Spawn stuff
	spawn()

func reset() -> void:
	weights = [ "fish" ]
	wave = 0
	wave_countdown = 0.0
	wave_queue.clear()
	spawn_timer = 0.0
	spawn_pickup_timer = 20.0
	for child in $Enemies.get_children():
		child.queue_free()
	for child in get_children():
		if !(child in children):
			child.queue_free()
