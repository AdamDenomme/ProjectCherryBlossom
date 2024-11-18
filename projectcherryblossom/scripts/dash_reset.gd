extends Node3D

var player_on_platform := false
var player: CharacterBody3D
var moving_stopped = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):  
		player_on_platform = true
		player = body
		player.total_dashes += 1  # Give an extra dash if desired
		moving_stopped = true


func _on_area_3d_body_exited(body):
	queue_free()
	if body == player:
		player_on_platform = false
		player = null
		moving_stopped = false


func _process(delta):
	if moving_stopped and player:
		player.target_velocity = Vector3.ZERO
		player.fall_acceleration = 0
		player.onDashReset = true
		if Input.is_action_just_pressed("dash"):
			var dash_direction = Vector2(player.global_transform.basis.x.x, player.global_transform.basis.y.y).normalized()
			player.velocity = Vector3(dash_direction.x, dash_direction.y, 0) * player.dash_speed  
			player.fall_acceleration = 75
			player.onDashReset = false
			player_on_platform = false
			player = null
			moving_stopped = false
