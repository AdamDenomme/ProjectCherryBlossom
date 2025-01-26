extends Panel

signal reload
signal quit

# Exported variables for buttons in the pause menu
@export var resume_button : Button
@export var retry_button : Button
@export var quit_button : Button

var current_button_index : int = 0  # Tracks which button is currently selected
var player : CharacterBody3D
var level : Node3D

# This function will be called when the game starts or when the pause screen is enabled
func _ready():
	# Find the level and player dynamically
	level = get_parent().get_parent()  # Assuming the level is the parent of this panel
	for child in level.get_children():
		if child.is_in_group("player"):
			player = child
	
	# Ensure that the PauseScreen starts off hidden
	self.visible = false
	
	# Find and connect the buttons
	resume_button = get_node("ResumeButton")
	retry_button = get_node("RetryButton")
	quit_button = get_node("QuitButton")
	
	# Connect the button signals to their corresponding functions
	resume_button.connect("pressed", Callable(self, "_on_resume_pressed"))
	retry_button.connect("pressed", Callable(self, "_on_retry_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	
	# Set the default button (usually Resume)
	select_button(current_button_index)
	
	# Debugging: print initialization confirmation
	print("PauseScreen initialized, ready to capture input.")

# This method handles the button selection and highlights the selected button
func select_button(index: int):
	# Reset all buttons to the default color (white)
	resume_button.add_theme_color_override("font_color", Color(1, 1, 1))  # White by default
	retry_button.add_theme_color_override("font_color", Color(1, 1, 1))
	quit_button.add_theme_color_override("font_color", Color(1, 1, 1))

	# Highlight the selected button (change color to red)
	if index == 0:
		resume_button.add_theme_color_override("font_color", Color(1, 0, 0))  # Red for selected
	elif index == 1:
		retry_button.add_theme_color_override("font_color", Color(1, 0, 0))
	elif index == 2:
		quit_button.add_theme_color_override("font_color", Color(1, 0, 0))

# This method will process input events (keyboard or other)
func _process(delta):
	# Only process input if the PauseScreen is visible
	if self.visible:
		# Handle navigation between buttons
		if Input.is_action_just_pressed("move_up"):
			print("Move Up Pressed")
			current_button_index = max(current_button_index - 1, 0)
			select_button(current_button_index)
		elif Input.is_action_just_pressed("move_down"):
			print("Move Down Pressed")
			current_button_index = min(current_button_index + 1, 2)  # 3 buttons in total: resume, retry, quit
			select_button(current_button_index)
		elif Input.is_action_just_pressed("select"):
			print("Select Pressed")
			press_selected_button()

# This method presses the selected button based on its index
func press_selected_button():
	if current_button_index == 0:
		_on_resume_pressed()
	elif current_button_index == 1:
		_on_retry_pressed()
	elif current_button_index == 2:
		_on_quit_pressed()

# The action for the Resume button
func _on_resume_pressed():
	# Unpause the game, hide the pause screen, and enable controls for the player
	print("Resume button pressed!")
	self.visible = false  # Hide the pause screen
	player.set_control_state(true)  # Re-enable player controls (gameplay)

# The action for the Retry button
func _on_retry_pressed():
	# Restart the scene
	print("Retry button pressed!")
	self.visible = false  # Hide the pause screen
	player.set_control_state(true)  # Re-enable player controls
	reload.emit()

# The action for the Quit button
func _on_quit_pressed():
	# Quit to main menu
	print("Quit button pressed!")
	self.visible = false  # Hide the pause screen
	#level.load_scene("res://scenes/objects/main_menu.tscn")  # Pivot to the main menu
	quit.emit()

# Toggle the visibility of the PauseScreen
func toggle_pause():
	# Show or hide the PauseScreen based on its current visibility
	self.visible = not self.visible
	
	# Disable or enable player controls
	player.set_control_state(not self.visible)
	
	# Pause or resume the game world
	for child in level.get_children():
		if child.is_in_group("environment"):
			child.paused = not self.visible
	
	print("PauseScreen visibility toggled:", self.visible)  # Debugging
