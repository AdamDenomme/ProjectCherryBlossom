extends Node3D

const ROT_SPEED = 2

# Define the signal for when the pickup is collected
signal collected

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		_collect_pickup()  # Call the method to handle collection

func _collect_pickup():
	emit_signal("collected")  # Notify that this pickup has been collected
	queue_free()  # Remove the pickup from the scene
	
	
func _process(delta):
	rotate_y(deg_to_rad(ROT_SPEED))
