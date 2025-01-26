extends Area3D

@export var particle_node_path: NodePath  
var wind_force := Vector3.ZERO
var player_in_wind := false
var player: CharacterBody3D
var wind_applied = false
var paused = false  
var particles: GPUParticles3D

func _ready():
	particles = get_node(particle_node_path) as GPUParticles3D
	if particles:
		particles.emitting = false  

func _on_body_entered(body: Node3D) -> void:
	wind_force = Vector3(-6, 0, 0)
	if body.is_in_group("player"):
		player_in_wind = true
		player = body
		wind_applied = true
		update_particle_emission() 
		print("wind step 1")

func _on_body_exited(body: Node3D) -> void:
	wind_force = Vector3.ZERO
	if body == player:
		player_in_wind = false
		player = null
		wind_applied = false
	update_particle_emission()  

func _process(delta):
	if not paused:
		if wind_applied and player:
			player.apply_wind_force(wind_force)

func set_pause_state(isPaused: bool):
	paused = isPaused
	update_particle_emission()  

func update_particle_emission():
	if particles:
		particles.emitting = wind_applied and not paused
