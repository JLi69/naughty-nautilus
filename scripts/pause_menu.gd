extends Control

@onready var player: Player = $/root/Main/Player
@onready var main_menu: Control = $/root/Main/CanvasLayer/MainMenu

func _process(_delta: float) -> void:
	if main_menu.visible:
		return

	if player.health <= 0:
		get_tree().paused = false
		hide()
		return

	if Input.is_action_just_pressed("ui_cancel"):
		visible = !visible
		get_tree().paused = visible
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _on_unpause_pressed() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _on_quit_pressed() -> void:
	hide()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$/root/Main/CanvasLayer/MainMenu.show()

