extends Area3D

@export var particle_node_path: NodePath  # Path to the GPUParticles3D node
var wind_force := Vector3.ZERO
var player_in_wind := false
var player: CharacterBody3D
var wind_applied = false
var paused = false  # Flag to freeze when paused
var particles: GPUParticles3D

func _ready():
	# Fetch the particles node and ensure it is configured correctly
	particles = get_node(particle_node_path) as GPUParticles3D
	if particles:
		particles.emitting = false  # Start with particles off

func _on_body_entered(body: Node3D) -> void:
	wind_force = Vector3(-4, 0, 0)
	if body.is_in_group("player"):
		player_in_wind = true
		player = body
		wind_applied = true
		if particles:
			particles.emitting = true  # Start emitting particles
		print("wind step 1")

func _on_body_exited(body: Node3D) -> void:
	wind_force = Vector3.ZERO
	if particles:
		particles.emitting = false  # Stop emitting particles
	if body == player:
		player_in_wind = false
		player = null
		wind_applied = false

func _process(delta):
	if not paused:
		if wind_applied and player:
			player.apply_wind_force(wind_force)

func set_pause_state(isPaused: bool):
	paused = isPaused
	if particles:
		particles.emitting = not isPaused  
