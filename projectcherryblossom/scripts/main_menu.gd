extends Control

@onready var play_button = get_node("ButtonContainer/PlayButton")
@onready var settings_button = get_node("ButtonContainer/SettingsButton")
@onready var scoreboard_button = get_node("ButtonContainer/ScoreboardButton")
@onready var exit_button = get_node("ButtonContainer/ExitButton")

var world : Node  # Reference to the world node, which contains the load_scene method

func _ready():
	#Find the world
	world = get_node("/root/World")  # Adjust the path to point to the World node in your scene tree
	
	# Connect button signals
	play_button.connect("pressed", Callable(self, "_on_play_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	scoreboard_button.connect("pressed", Callable(self, "_on_scoreboard_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))
	#get_tree().get_root().set_transparent_background(true)
	
# Function to start the game
func _on_play_pressed():
	print("Play button pressed!")
	world.load_scene("res://scenes/levels/FirstLevel.tscn")  # CHANGE TO DEMO LEVEL

# Function to open settings menu
func _on_settings_pressed():
	print("Settings button pressed!")
	#get_tree().change_scene_to_file("res://settings.tscn")  # CHANGE TO SETTING SCENE

# Function to open the scoreboard
func _on_scoreboard_pressed():
	print("Scoreboard button pressed!")
	#get_tree().change_scene_to_file("res://scenes/Scoreboard.tscn")  # CHANGE TO SCOREBOARD SCENE

# Function to quit the game
func _on_exit_pressed():
	print("Exit button pressed!")
	get_tree().quit()  # This will close the game
