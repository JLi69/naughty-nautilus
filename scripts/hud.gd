extends Control

var health_icons: Array[Sprite2D] = []

var animation_time: float = 0.0

func _ready() -> void:
	$Health/HealthIcon.hide()

func update_health(health_amt: int) -> void:
	if health_amt <= 0:
		$Health.hide()
		$HealthLabel.hide()
		return
	else:
		$Health.show()
		$HealthLabel.show()

	while health_icons.size() > health_amt and !health_icons.is_empty():
		health_icons[health_icons.size() - 1].queue_free()
		health_icons.pop_back()

	while health_icons.size() < health_amt:
		var health_icon: Sprite2D = $Health/HealthIcon.duplicate()
		health_icon.show()
		if health_icons.is_empty():
			health_icon.position = Vector2.ZERO
		else:
			health_icon.position = health_icons[health_icons.size() - 1].position + Vector2(40.0, 0.0)
		$Health.add_child(health_icon)
		health_icons.push_back(health_icon)

func pulse_last_health_icon() -> void:
	if health_icons.is_empty():
		return

	for health_icon: Sprite2D in health_icons:
		health_icon.scale = $Health/HealthIcon.scale

	var sprite_scale: float = 1.0
	if health_icons.size() == 1:
		sprite_scale = lerpf(0.8, 1.2, (sin(animation_time * 4.0) + 1.0) / 2.0)
	else:
		sprite_scale = lerpf(0.9, 1.1, (sin(animation_time * 2.0) + 1.0) / 2.0)
	health_icons[health_icons.size() - 1].scale = sprite_scale * $Health/HealthIcon.scale

func update_animation_time(delta: float) -> void:
	animation_time += delta

func update_stats(score: int, time: float) -> void:
	$Stats/Score.text = "Score: %d" % score
	var minutes: int = floori(time / 60.0)
	var seconds: int = floori(time - minutes * 60.0)
	$Stats/Time.text = "%d:%02d" % [ minutes, seconds ]

func update_wave_info(wave: int, enemies_left: float) -> void:
	if wave < 0:
		$WaveInfo.hide()
		return
	else:
		$WaveInfo.show()
	$WaveInfo/Wave.text = "Wave: %d" % wave 
	$WaveInfo/EnemiesLeft.text = "Enemies Left: %d" % enemies_left

func update_wave_countdown(time: float) -> void:
	if time <= 0.0:
		$WaveCountdown.hide()
	else:
		$WaveCountdown.show()
	$WaveCountdown.text = "NEXT WAVE: %ds" % roundi(time)
