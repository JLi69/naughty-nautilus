class_name Main

extends Node2D

@onready var player: Player = $Player

var time: float = 0.0

var score: int = 0
var add_score: int = 0
var combo_timer: float = 0.0
var combo: int = 0
const COMBO_TIME: float = 1.25

var high_score: int = 0

func _ready() -> void:
	get_tree().paused = true

	var file = FileAccess.open("user://high_score", FileAccess.READ)
	var content: String = file.get_as_text()
	high_score = int(content)

func update_score(amt: int) -> void:
	add_score += amt
	combo += 1
	combo_timer = COMBO_TIME
	$CanvasLayer/Control/Hud.pulse_combo_timer()

func _process(delta: float) -> void:
	$CanvasLayer/Control/Hud.update_health(player.health)
	$CanvasLayer/Control/Hud.pulse_last_health_icon()
	$CanvasLayer/Control/Hud.update_animation_time(delta)

	if player.health > 0:
		time += delta

	$CanvasLayer/Control/Hud.update_stats(score, time)
	var level: Level = get_node_or_null("Level")
	if level:
		$CanvasLayer/Control/Hud.update_wave_info(level.wave, level.get_enemies_left())
		if level.wave > 1:
			$CanvasLayer/Control/Hud.update_wave_countdown(level.wave_countdown)
		else:
			$CanvasLayer/Control/Hud.update_wave_countdown(0.0)
		$CanvasLayer/Control/Hud.update_combo_text(add_score, combo)
	else:
		$CanvasLayer/Control/Hud.update_wave_info(-1, 0)
		$CanvasLayer/Control/Hud.update_wave_countdown(0.0)
		$CanvasLayer/Control/Hud.update_combo_text(0, 0)

	if combo_timer > 0.0:
		combo_timer -= delta
	elif add_score > 0:
		if player.health > 0:
			score += add_score * combo
		add_score = 0
		combo = 0

func reset() -> void:
	$CanvasLayer/Control/Hud.update_wave_info(-1, 0)
	$CanvasLayer/Control/Hud.update_wave_countdown(0.0)
	$CanvasLayer/Control/Hud.update_combo_text(0, 0)
	time = 0.0
	score = 0
	combo_timer = 0.0
	combo = 0
	player.reset()
	$Level.reset()
	player.global_position = $Level/SpawnPoint.global_position

func save_high_score() -> void:
	var file = FileAccess.open("user://high_score", FileAccess.WRITE)
	file.store_string(str(high_score))
