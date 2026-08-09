class_name Sfx

static var sfx_list: Dictionary = {
	"bubbles" : preload("uid://cgjiia4ndx8qu"),
	"splat" : preload("uid://d0x3fhrdsf0q3"),
	"explosion" : preload("uid://0w1hcwfeeevl")
}

static func play_at(parent: Node, pos: Vector2, id: String) -> void:
	if !(id in sfx_list):
		return
	var sfx: AudioStreamPlayer2D = sfx_list[id].instantiate()
	sfx.global_position = pos
	parent.add_child(sfx)
	sfx.play()
	sfx.connect("finished", sfx.queue_free)
