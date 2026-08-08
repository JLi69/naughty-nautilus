class_name Main

extends Node2D

@onready var player: Player = $Player

var time: float = 0.0

var score: int = 0
var add_score: int = 0
var combo_timer: float = 0.0
var combo: int = 0
const COMBO_TIME: float = 1.25

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func update_score(amt: int) -> void:
	add_score += amt
	combo += 1
	combo_timer = COMBO_TIME
	$CanvasLayer/Control/Hud.pulse_combo_timer()

func _process(delta: float) -> void:
	$CanvasLayer/Control/Hud.update_health(player.health)
	$CanvasLayer/Control/Hud.pulse_last_health_icon()
	$CanvasLayer/Control/Hud.update_animation_time(delta)

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
		score += add_score * combo
		add_score = 0
		combo = 0

