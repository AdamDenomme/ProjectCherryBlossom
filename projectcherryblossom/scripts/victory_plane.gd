extends Area3D

const ROT_SPEED = 2

# Called when a collision occurs
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Check if the body is the player
		#DEBUG
		#print("Player hit by victory plane!")
		body.win.emit()

func _process(delta):
	rotate_y(deg_to_rad(ROT_SPEED))
