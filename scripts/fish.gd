class_name Fish

extends CharacterBody2D

@onready var main: Main = $/root/Main

@export var speed: float = 80.0
# In degrees per second
@export var rotation_speed: float = 60.0

@onready var speed_scale = randf_range(0.8, 1.2)

func _process(delta: float) -> void:
	var dir: Vector2 = Vector2(cos(rotation), sin(rotation))
	velocity = speed * speed_scale * dir

	# Update rotation
	var diff: Vector2 = (main.player.global_position - global_position).normalized()
	var angle_diff: float = delta * deg_to_rad(rotation_speed)
	var dir1: Vector2 = Vector2(cos(rotation + angle_diff), sin(rotation + angle_diff))
	var dir2: Vector2 = Vector2(cos(rotation - angle_diff), sin(rotation - angle_diff))
	if dir1.dot(diff) > dir2.dot(diff):
		rotation += angle_diff
	elif dir1.dot(diff) < dir2.dot(diff):
		rotation -= angle_diff

	if abs(rotation) < PI / 2:
		$AnimatedSprite2D.scale.y = 1.0
	else:
		$AnimatedSprite2D.scale.y = -1.0

func _physics_process(_delta: float) -> void:
	move_and_slide()
