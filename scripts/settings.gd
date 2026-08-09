extends Control

@onready var main: Main = $/root/Main

func _ready() -> void:
	$VBoxContainer/Confirm.hide()

	# Load settings
	var settings_file = FileAccess.open("user://settings", FileAccess.READ)

	# Apply volume settings
	if settings_file:
		var master_bus = AudioServer.get_bus_index("Master")
		var volume = float(settings_file.get_line())
		AudioServer.set_bus_volume_linear(master_bus, volume / 100.0)

		var music_bus = AudioServer.get_bus_index("Music")
		var music_volume = float(settings_file.get_line())
		AudioServer.set_bus_volume_linear(music_bus, music_volume / 100.0)

func _process(_delta: float) -> void:
	if !visible:
		return

	var volume = $VBoxContainer/MasterVolume/HSlider.value
	$VBoxContainer/MasterVolume/Label.text = "Master Volume (%d%%)" % int(volume)

	var music_volume = $VBoxContainer/MusicVolume/HSlider.value
	$VBoxContainer/MusicVolume/Label.text = "Music Volume (%d%%)" % int(music_volume)

func apply_settings() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	var volume = $VBoxContainer/MasterVolume/HSlider.value
	AudioServer.set_bus_volume_linear(master_bus, volume / 100.0)

	var music_bus = AudioServer.get_bus_index("Music")
	var music_volume = $VBoxContainer/MusicVolume/HSlider.value
	AudioServer.set_bus_volume_linear(music_bus, music_volume / 100.0)

func _on_back_pressed() -> void:
	hide()
	main.play_sfx("Click")

	# Apply volume settings
	apply_settings()
	save_settings()

func activate() -> void:
	show()
	$VBoxContainer/ResetHighScore.show()
	$VBoxContainer/Confirm.hide()

	# Set volume sliders
	var master_bus = AudioServer.get_bus_index("Master")
	var volume: float = AudioServer.get_bus_volume_linear(master_bus)
	$VBoxContainer/MasterVolume/HSlider.value = volume * 100.0
	$VBoxContainer/MasterVolume/Label.text = "Master Volume (%d%%)" % int(volume * 100.0)

	var music_bus = AudioServer.get_bus_index("Music")
	var music_volume: float = AudioServer.get_bus_volume_linear(music_bus)
	$VBoxContainer/MusicVolume/HSlider.value = music_volume * 100.0
	$VBoxContainer/MusicVolume/Label.text = "Music Volume (%d%%)" % int(volume * 100.0)

func _on_reset_high_score_button_pressed() -> void:
	$VBoxContainer/ResetHighScore.hide()
	$VBoxContainer/Confirm.show()
	main.play_sfx("Click")

func _on_reset_pressed() -> void:
	$VBoxContainer/ResetHighScore.show()
	$VBoxContainer/Confirm.hide()
	main.high_score = 0
	main.save_high_score()
	main.play_sfx("Click")

func _on_cancel_pressed() -> void:	
	main.play_sfx("Click")
	$VBoxContainer/ResetHighScore.show()
	$VBoxContainer/Confirm.hide()

func save_settings() -> void:
	var settings_file = FileAccess.open("user://settings", FileAccess.WRITE)
	settings_file.store_line(str($VBoxContainer/MasterVolume/HSlider.value))
	settings_file.store_line(str($VBoxContainer/MusicVolume/HSlider.value))

func _on_restore_defaults_pressed() -> void:
	main.play_sfx("Click")
	$VBoxContainer/MasterVolume/HSlider.value = 100.0
	$VBoxContainer/MusicVolume/HSlider.value = 100.0
	apply_settings()
	save_settings()
