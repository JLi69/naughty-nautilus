class_name Healthbar

extends ColorRect

func set_health(health: float, max_health: float) -> void:
	if health >= max_health:
		hide()
	else:
		show()
	$ColorRect.size.x = health / max_health * size.x
