extends GPUParticles3D

@export var spawn_area: NodePath  # Path to the Area3D or CollisionShape3D

var collision_box: BoxShape3D

func _ready():
	if spawn_area:
		var collision_shape = get_node(spawn_area) as CollisionShape3D
		if collision_shape and collision_shape.shape is BoxShape3D:
			collision_box = collision_shape.shape
			#emission_box_extents = collision_box.extents
		else:
			push_error("Assigned spawn_area does not have a BoxShape3D.")
	else:
		push_error("spawn_area path is not set.")
