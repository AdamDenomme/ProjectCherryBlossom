extends CharacterBody3D

var player_on_platform := false
var player: CharacterBody3D
var moving = false

var destruction_timer: Timer
var respawn_timer: Timer

@onready var collision = get_node("CollisionShape")

var platform_direction = Vector3.ZERO  
var player_move_direction = Vector3.ZERO 

var paused = false  

func _ready():
	if name.contains("Left") or name.contains("Right"):
		platform_direction = Vector3.LEFT if name.contains("Left") else Vector3.RIGHT
		player_move_direction = Vector3.UP  

func _on_control_area_body_entered(body):
	if body.is_in_group("player"):
		player_on_platform = true
		player = body
		moving = true

func _on_control_area_body_exited(body):
	if body == player:
		player_on_platform = false
		player = null
		# destruction_timer.start()

func _process(delta):
	# Toggle paused state
	if Input.is_action_just_pressed("pause"):
		paused = not paused

	if moving and not paused:
		position += platform_direction * 4 * delta

	if player_on_platform and player:
		var direction = Vector3.ZERO

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
