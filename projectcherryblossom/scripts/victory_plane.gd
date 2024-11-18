extends Area3D

# Called when a collision occurs
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Check if the body is the player
		#DEBUG
		#print("Player hit by victory plane!")
		body.win.emit()
