class_name Explosion

extends GPUParticles2D

func _ready() -> void:
	emitting = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("shell") or area.is_in_group("player_hit"):
		$/root/Main/Player.damage(4)
	elif area.is_in_group("fish"):
		var parent: Node = area.get_parent()
		if parent is Fish:
			parent.health -= 16.0

func _on_finished() -> void:
	queue_free()
