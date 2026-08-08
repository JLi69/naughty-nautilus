class_name Main

extends Node2D

@onready var player: Player = $Player

var time: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(delta: float) -> void:
	$CanvasLayer/Control/Hud.update_health(player.health)
	$CanvasLayer/Control/Hud.pulse_last_health_icon()
	$CanvasLayer/Control/Hud.update_animation_time(delta)

	time += delta

	$CanvasLayer/Control/Hud.update_stats(0, time)
	var level: Level = get_node_or_null("Level")
	if level:
		$CanvasLayer/Control/Hud.update_wave_info(level.wave, level.get_enemies_left())
		if level.wave > 1:
			$CanvasLayer/Control/Hud.update_wave_countdown(level.wave_countdown)
		else:
			$CanvasLayer/Control/Hud.update_wave_countdown(0.0)
	else:
		$CanvasLayer/Control/Hud.update_wave_info(-1, 0)
		$CanvasLayer/Control/Hud.update_wave_countdown(0.0)
