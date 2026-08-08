class_name Main

extends Node2D

@onready var player: Player = $Player

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
