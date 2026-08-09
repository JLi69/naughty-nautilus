extends Control

@onready var main: Main = $/root/Main

func _ready() -> void:
	if OS.get_name() == "Web":
		$VBoxContainer/Quit.hide()

func _process(_delta: float) -> void:
	if !visible:
		return
	$VBoxContainer/HighScore.text = "High Score: %d" % main.high_score

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	main.reset()

func _on_credits_pressed() -> void:
	$Credits.show()
