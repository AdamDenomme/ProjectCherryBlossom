extends Control



func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/objects/main_menu.tscn")


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1280,720))
