extends Control

@onready var main: Main = $/root/Main
var new_high_score: bool = false

func _process(_delta: float) -> void:
	if !visible:
		return

	$VBoxContainer/Stats.text = "Score: %d" % main.score
	var minutes: int = floori(main.time / 60.0)
	var seconds: int = floori(main.time - minutes * 60.0)
	if new_high_score:	
		$VBoxContainer/Stats.text += "\nNew High Score!"
	$VBoxContainer/Stats.text += "\nTime Survived: %d:%02d" % [ minutes, seconds ]

func activate() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	new_high_score = main.score > main.high_score
	if new_high_score:
		main.high_score = main.score
		main.save_high_score()

func _on_quit_pressed() -> void:
	hide()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$/root/Main/CanvasLayer/MainMenu.show()
