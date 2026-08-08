extends Control

func _process(_delta: float) -> void:
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
