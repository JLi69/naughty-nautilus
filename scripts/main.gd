class_name Main

extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(delta: float) -> void:
	$CanvasLayer/Control/Hud.update_health(player.health)
	$CanvasLayer/Control/Hud.pulse_last_health_icon()
	$CanvasLayer/Control/Hud.update_animation_time(delta)
