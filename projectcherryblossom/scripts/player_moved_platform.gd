extends CharacterBody3D

var player_on_platform := false
var player: CharacterBody3D
var moving = false

var platform_direction = Vector3.ZERO  
var player_move_direction = Vector3.ZERO 

var paused = false  # Flag to freeze when paused

func _ready():
	if name.contains("Left") or name.contains("Right"):
		platform_direction = Vector3.LEFT if name.contains("Left") else Vector3.RIGHT
		player_move_direction = Vector3.UP  

func _on_control_area_body_entered(body):
	if body.is_in_group("player"):
		player_on_platform = true
		player = body
		moving = true
		if player.target_velocity.y >= 5:
				player.fall_velocity = 75
	
	if body.is_in_group("environment"):
		queue_free()


func _on_control_area_body_exited(body):
	if body == player:
		player_on_platform = false
		player = null

func _process(delta):
	if not paused:
		if moving:
			# Move the platform in the specified direction
			position += platform_direction * 4 * delta

		if player_on_platform and player:
			var direction = Vector3.ZERO

			# Allow the player to move only in the restricted direction
			if player_move_direction == Vector3.UP:
				if Input.is_action_pressed("move_up"):
					direction.y += 1
				if Input.is_action_pressed("move_down"):
					direction.y -= 1

			var speed = 8.0
			position += direction * speed * delta


			if Input.is_action_pressed("jump"):
				player_on_platform = false
				player = null

# Setter to change the state remotely
#func set_pause_state(isPaused: bool):
