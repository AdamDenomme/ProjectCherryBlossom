extends StaticBody3D

var destruction_timer : Timer
var respawn_timer : Timer
@onready var collision = get_node("CollisionShape3D")
@onready var area = get_node("Area3D")
var pause_screen : Panel


func _ready():
	#Parse the timer
	destruction_timer = get_node("DestroyTimer")
	respawn_timer = get_node("RespawnTimer")
	
func _on_area_3d_body_entered(_body: Node3D) -> void:
	if _body.is_in_group("player"):
		destruction_timer.start()

func _on_destroy_timer_timeout() -> void:
	collision.disabled = true
	hide()
	respawn_timer.start()

# Called every frame to check the pause state
func _process(delta):
	destruction_timer.set_paused(get_parent().get_node("UserInterface").get_node("PauseScreen").visible) #Check if the pause screen is visible
	respawn_timer.set_paused(get_parent().get_node("UserInterface").get_node("PauseScreen").visible)

func _on_respawn_timer_timeout():
	collision.disabled = false
	show()
	
