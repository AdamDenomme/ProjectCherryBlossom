extends CharacterBody3D

signal hit #Signal for handling player death
signal win #Signal for handling player win condition

#How fast the player moves in meters/second
@export var speed = 14
#The downward acceleration when airborne (typically gravity) in meters/second^2
@export var fall_acceleration = 75
#Vertical impulse applied to the character upon jumping
@export var jump_impulse = 20
#Track whether the character is in a playable state
@export var controls_enabled = true
#Spawn location
@export var spawn: Marker3D
@export var direction = Vector3.ZERO
@export var onDashReset = false
@export var hitPlatform = false

var paused = false


#Coyote Timer
@onready var coyote_timer = get_node("CoyoteTime")
var was_on_floor = is_on_floor()

# Variables for Dashing
var total_dashes = 1
var dashing = 0
var dash_speed = 75  # Initial dash speed burst
var dash_deceleration = 100  # Deceleration factor during dash


#Variables for AfterImage
#var afterimage_scene: PackedScene = preload("res://after_image.tscn")
var is_dashing = false
var is_jumping = false

var external_force := Vector3.ZERO

 
#Player velocity, defaulted to 0
var target_velocity = Vector3.ZERO


#region SFX References
var landing_sfx_player : AudioStreamPlayer
var jumping_sfx_player : AudioStreamPlayer
var pickup_sfx_player : AudioStreamPlayer
#endregion

func _ready():
	landing_sfx_player = get_node("LandingSFXPlayer")
	jumping_sfx_player = get_node("JumpingSFXPlayer")
	pickup_sfx_player = get_node("PickupSFXPlayer")

func _physics_process(delta):
	if Input.is_action_pressed("pause"):
		paused = not paused
	
	if paused == true:
		$Pivot/foxidle/run_anim.speed_scale = 0
	# Local variable to store the input direction
	if controls_enabled:  # Check if the player is playable
		direction = Vector3.ZERO
		$Pivot/foxidle/idle_anim.speed_scale = 1.2
		
		# Handle landing SFX
		if is_on_floor():
			# Only play the landing sound when transitioning from air to floor
			if !was_on_floor:
				landing_sfx_player.play()  # Play the landing sound effect
			# Set the current state of the player (on the floor)
			was_on_floor = true
			is_jumping = false  # Reset the jumping flag
		else:
			# The player is not on the floor, mark them as in the air
			was_on_floor = false

		# Check for each move input and update the direction accordingly
		if not onDashReset:
			if Input.is_action_pressed("move_right"):
				direction.x += 1
				$Pivot/foxidle.scale.x = -abs($Pivot/foxidle.scale.x)  # Face right
			if Input.is_action_pressed("move_left"):
				direction.x -= 1
				$Pivot/foxidle.scale.x = abs($Pivot/foxidle.scale.x)  # Face left
		if Input.is_action_pressed("move_up"):
			direction.y += 1
		if Input.is_action_pressed("move_down"):
			direction.y -= 1

		# Normalize the direction
		if direction != Vector3.ZERO:
			direction = direction.normalized()
		
		# Animation control
		if direction.x != 0 and not (direction.y > 0 and direction.x == 0):  # Running left or right
			$Pivot/foxidle/run_anim.play("Armature_1Action")
			$Pivot/foxidle/run_anim.speed_scale = 8
		elif direction == Vector3.ZERO:
			$Pivot/foxidle/run_anim.stop()
			$Pivot/foxidle/reset.play("RESET")
		elif direction.y > 0 and direction.x == 0:  # Moving up only
			$Pivot/foxidle/run_anim.stop()
			$Pivot/foxidle/reset.play("RESET")
			


		# Horizontal Velocity
		if dashing == 1 and total_dashes >= 1:
			target_velocity.x = (direction.x * dash_speed) * 1.25
			target_velocity.y = (direction.y * dash_speed) / 2
		else:
			target_velocity.x = direction.x * speed
		
		# Vertical Velocity
		if not is_on_floor() and dashing == 0:
			if was_on_floor:
				coyote_timer.start()
			target_velocity.y -= fall_acceleration * delta

		if is_on_floor():
			if total_dashes <= 2:
				total_dashes = 2
			coyote_timer.stop()

		# Jumping
		if Input.is_action_just_pressed("jump") and (is_on_floor() or not coyote_timer.is_stopped()):
			target_velocity.y = jump_impulse * 1.2
			is_jumping = true
			jumping_sfx_player.play()

		# Dashing logic
		if Input.is_action_just_pressed("dash") and total_dashes > 1:
			if not is_on_floor():
				is_dashing = true
				dashing = 1
				total_dashes -= 1
				self.get_node("DashTimer").start()
				self.get_node("DashSound").play()
		
		target_velocity += external_force
		external_force = Vector3.ZERO

		# Decelerate during dash
		if dashing == 1:
			target_velocity.x -= dash_deceleration * delta
			target_velocity.y -= dash_deceleration * delta

		# Collision
		for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			
			# Ground Collision
			if collision.get_collider() == null:
				continue  # We don't care about floor collisions
			
			# Pickup Collision
			if collision.get_collider().is_in_group("pickup"):
				var pickup = collision.get_collider()  # Get the pickup in question
				# Collect the item
				pickup.collect()
				# Prevent multi-instance duplicate calls
				break
			if collision.get_collider().is_in_group("Branches") and hitPlatform == true:
				target_velocity.y = -5
				print("Hit Bottom of Platform")

		# Move the character
		velocity = target_velocity
		move_and_slide()
		#self.get_node("Pivot").rotation.x = PI / 6 * velocity.y / jump_impulse

	
func _on_dash_timer_timeout() -> void:
	dashing = 0
	is_dashing = false
  
func set_control_state(isPlayable : bool):
	controls_enabled = isPlayable
	
func apply_wind_force(force: Vector3):
	external_force += force
	
func play_pickupsfx():
	print("Collected a pickup!")
	#Play a sound
	pickup_sfx_player.play()
