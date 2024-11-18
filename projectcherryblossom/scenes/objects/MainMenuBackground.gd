extends TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var text = get_parent().get_node("SubViewportContainer/SubViewport").get_texture()
	texture = text
