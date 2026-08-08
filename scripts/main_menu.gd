extends Control

@onready var main: Main = $/root/Main

func _ready() -> void:
	if OS.get_name() == "Web":
		$VBoxContainer/Quit.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	# TODO: reset everything
