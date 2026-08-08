extends Control

@onready var main: Main = $/root/Main

func _process(_delta: float) -> void:
	if !visible:
		return

	$VBoxContainer/Stats.text = "Score: %d" % main.score
	var minutes: int = floori(main.time / 60.0)
	var seconds: int = floori(main.time - minutes * 60.0)
	$VBoxContainer/Stats.text += "\nTime Survived: %d:%02d" % [ minutes, seconds ]

func activate() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_quit_pressed() -> void:
	hide()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$/root/Main/CanvasLayer/MainMenu.show()
