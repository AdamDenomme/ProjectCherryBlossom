extends Marker3D

#Extents at which the camera is allowed to move to
@export var x_lowerbound = 0 #Lateral camera lower bound
@export var x_upperbound = 0 #Lateral camera upper bound
@export var y_lowerbound = 0 #Vertical camera lower bound
@export var y_upperbound = 0 #Vertical camera upper bound

#Flag to determine whether the camera is allowed to move
@export var staticCamera = (x_lowerbound != 0 and x_upperbound != 0 and y_lowerbound != 0 and y_upperbound != 0)
#Flag to allow the camera to move entirely freely
@export var freeRoamCamera = false

@export var offset = Vector3(0, 5, 20)

@export var original_position: Vector3  # To store the camera's original position
var is_panning_down := false
var able_to_pan := false
var pan_speed := 5.0  
var target_position: Vector3 


@export var player: CharacterBody3D
@export var spawn: Marker3D

#Goal - Move the camera to try to keep the player as close to center as possible 
func _ready():
	#Find the relevant references
	for child in get_parent().get_children(): #Search every child node
		if child.is_in_group("playerspawn"): #If the node belongs to  group "spawn"
			spawn = child #Find the spawn
			print("Found Spawn for Camera")
		if child.is_in_group("player"):
			player = child #Find the player
		for branch in get_tree().get_nodes_in_group("Branches"):
			branch.connect("player_platform_status", Callable(self, "_on_player_platform_status"))
		for dashReset in get_tree().get_nodes_in_group("DashReset"):
			dashReset.connect("Dash_Reset_status", Callable(self, "_on_Dash_Reset_status"))
	
	#Settle the camera position
	position = spawn.position
	position += offset
	
	look_at_from_position(position, spawn.position)
	
	original_position = global_transform.origin  # Save the original position of Camera3D
	
	
	
func _process(delta : float) -> void:
	position = position.lerp(target_position, pan_speed * delta)
	

	if player:
		#Get the players current position
		var player_position = player.global_transform.origin
		
		#Offset it as in ready
		var camera_position = player_position + offset

		if not freeRoamCamera:
			camera_position.x = clamp(camera_position.x, x_lowerbound, x_upperbound)
			camera_position.y = clamp(camera_position.y, y_lowerbound, y_upperbound)
		

		if not staticCamera and is_panning_down == false:
			position = camera_position #Adjust the camera's position accordingly
			
func _on_player_platform_status(on_platform: bool):
	is_panning_down = on_platform
	if is_panning_down:
		target_position = position - Vector3(0, 3, 0)  # Pan down
	else:
		target_position = position + Vector3(0, 3, 0)

		
func _on_Dash_Reset_status(on_platform: bool):
	able_to_pan = on_platform
	var original_position = target_position
	if able_to_pan:
		print("is Able to Pan")
		if Input.is_action_just_pressed("move_up"):
			target_position = position + Vector3(0, 3, 0)
		if Input.is_action_just_pressed("move_down"):
			target_position = position - Vector3(0, 3, 0)
		if Input.is_action_just_pressed("move_left"):
			target_position = position - Vector3(3, 0, 0)
		if Input.is_action_just_pressed("move_right"):
			target_position = position + Vector3(3, 0, 0)
	else:
		target_position = original_position
	
