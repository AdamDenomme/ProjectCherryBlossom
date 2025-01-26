extends StaticBody3D


var player_on_platform := false
var player: CharacterBody3D
signal player_platform_status(on_platform: bool)

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):  
		print("entered area")
		player_on_platform = true
		player = body
		emit_signal("player_platform_status", true)  
	#if _is_hitting_from_bottom(body):
			#player.target_velocity.y = -5
			#player_on_platform = false
			#player = null
			#print("hit from bottom")
			#emit_signal("player_platform_status", false)  



func _on_area_3d_body_exited(body):
	if body == player:
		player_on_platform = false
		player = null
		emit_signal("player_platform_status", false)  
		
#func _is_hitting_from_bottom(body: Node) -> bool:
	#return body.global_transform.origin.y < self.global_transform.origin.y
	

func _process(delta):
	if player_on_platform and Input.is_action_just_pressed("jump"):
		player.target_velocity.y += 20  
		player_on_platform = false
		player = null
		emit_signal("player_platform_status", false)
