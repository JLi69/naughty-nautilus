extends CharacterBody2D

func _ready() -> void:
	pass

func rotate_to_mouse() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var diff: Vector2 = mouse_pos - global_position
	$AnimatedSprite2D.rotation = diff.angle() + deg_to_rad(180.0)

	if abs(diff.angle()) < PI / 2:
		$AnimatedSprite2D.scale.y = -1.0
	else:
		$AnimatedSprite2D.scale.y = 1.0

func _process(_delta: float) -> void:
	rotate_to_mouse()

func _physics_process(_delta: float) -> void:
	move_and_slide()
