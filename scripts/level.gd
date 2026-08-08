class_name Level

extends Node2D

var wave: int = 0
const WAVE_COUNTDOWN_TIME: float = 5.0
var wave_countdown: float = 0.0

var wave_queue: Array = []

var spawn_timer: float = 0.0

@onready var tile_size: float = $Walls.tile_set.tile_size.x
@onready var player: Player = $/root/Main/Player

static var enemy_scenes: Dictionary = {
	"fish" : preload("uid://btnoj88sbgiww"),
}

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

static func get_enemies(current_wave: int) -> Array:
	var enemies = []

	var count_range = get_count_range(current_wave)
	var count = randi_range(count_range[0], count_range[1])

	for i in range(count):
		enemies.push_back("fish")

	return enemies

func prepare_wave() -> void:
	wave += 1
	wave_countdown = WAVE_COUNTDOWN_TIME
	spawn_timer = randf_range(10.0, 15.0)

	var spawn_counts: int = ceili(float(wave) / 2.0)
	for i in range(spawn_counts):
		wave_queue.push_back(get_enemies(wave))

# Returns true upon success, false otherwise
func try_spawning(enemy_scene: PackedScene, center_pos: Vector2) -> bool:
	var dist: float = randf_range(10.0, 15.0) * tile_size
	var angle: float = randf_range(0.0, 2.0 * PI)
	var pos: Vector2 = dist * Vector2(cos(angle), sin(angle)) + center_pos
	pos.x = tile_size * floor(pos.x / tile_size) + tile_size / 2.0
	pos.y = tile_size * floor(pos.y / tile_size) + tile_size / 2.0
	
	var tile_pos: Vector2i = Vector2i(floori(pos.x / tile_size), floori(pos.y / tile_size))
	if $Walls.get_cell_tile_data(tile_pos):
		return false

	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	$Enemies.add_child(enemy)
	return true

func spawn() -> void:
	if get_enemies_left() > 0 and spawn_timer >= 0.0:
		return

	if wave_queue.is_empty():
		return

	while get_enemies_left() <= 0:
		for enemy_id: String in wave_queue[wave_queue.size() - 1]:
			var enemy_scene = enemy_scenes[enemy_id]
			for i in range(4):
				if try_spawning(enemy_scene, player.global_position):
					break
	wave_queue.pop_back()

func _process(delta: float) -> void:
	if player.health <= 0:
		wave_countdown = 0

	if get_enemies_left() == 0 and wave_queue.is_empty():
		prepare_wave()

	if wave_countdown > 0.0:
		wave_countdown -= delta
		return

	# Spawn stuff
	spawn()
