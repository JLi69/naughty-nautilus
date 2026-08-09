class_name Sfx

static var sfx_list: Dictionary = {
	"bubbles" : preload("uid://cgjiia4ndx8qu"),
}

static func play_at(parent: Node, pos: Vector2, id: String) -> void:
	if !(id in sfx_list):
		return
	var sfx: AudioStreamPlayer2D = sfx_list[id].instantiate()
	sfx.global_position = pos
	parent.add_child(sfx)
	sfx.play()
	sfx.connect("finished", sfx.queue_free)
