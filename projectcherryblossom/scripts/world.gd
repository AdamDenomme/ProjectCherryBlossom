extends Node3D

var debug = true  # Debug flag for enabling/disabling debug information

#region Scene References
var current_scene : Node #For tracking the scene we are currently running
var current_scene_path : String #For tracking the path to the scene we are currently running
var strawberries_container: HBoxContainer #For dynamically displaying the available pickups remaining in the level
var collected_count: int = 0  #Counter for collected pickups
var player : CharacterBody3D #Player reference for ease of access
var spawn : Marker3D #Spawn point reference for ease of access
var player_lives : int = 3 #Life counter
var level_timer : Timer #Timer to track the playtime in a level
var level_start_time : float = 0.0
var level_elapsed_time :float = 0.0
var level_index = 0 #Base index for the level location for level regeneration
var timer_label : Label #UI label to display the timer
var victory_screen : Panel
var victory_label : Label
var victory_background : ColorRect
#endregion

#region Level Data
var total_time : float = 0.0 #Total time elapsed
var total_pickups : int = 0 #Total pickups collected
#endregion

#region Level Paths
var main_menu_path = "res://scenes/objects/main_menu.tscn"
var demo_level_path = "res://scenes/levels/DemoTestingLevel.tscn"
var level1_path = "res://scenes/levels/DemoTestingLevel.tscn"
var level2_path = "res://scenes/levels/tester_level.tscn"
var level3_path = "res://scenes/levels/tester_level.tscn"
var final_level_path = "res://scenes/levels/tester_level.tscn"
var scoreboard_path = "res://scenes/objects/scoreboard.tscn"
#endregion

#region UI References
var user_interface : Control
var fade_rect : ColorRect  # For fade effect (death)
var fade_duration : float = 0.5  # Duration for fade effect
var life_counter_label : Label
var strawberry_count : int
#endregion

#Start the game in main menu
func _ready():
	load_scene(main_menu_path)  # Start by loading the main menu

#Run the timer each tick
func _process(delta :float):
	#Calculate the elapsed time from the start of the level
	if level_timer:
		if not level_timer.paused  and level_timer.is_inside_tree():
			level_elapsed_time = (Time.get_ticks_msec() - level_start_time) / 1000.0 #Convert to secconds
			timer_label.text = format_time(level_elapsed_time)

#region LOADER
# Function to load a new scene and replace the current one
func load_scene(scene_path: String) -> void:
	# Ensure the current scene is properly cleaned up
	if current_scene:
		current_scene.queue_free()
		level_timer = null
		victory_screen = null
		current_scene = null  # Explicitly null out reference after freeing the scene
	
	# Load the new scene and instantiate it
	var new_scene = load(scene_path).instantiate()
	get_tree().current_scene = new_scene  # Set as the active scene in the tree
	

	# Add the new scene to the root node
	add_child(new_scene)
	
	# Store a reference to the current scene for future unloading
	current_scene = new_scene
	#Store a reference to the path of the current scene for future handling
	current_scene_path = scene_path

	#Modify the index of the level we're loading
	if scene_path == demo_level_path:
		level_index = 0
	elif scene_path == level1_path:
		level_index = 1
	elif scene_path == level2_path:
		level_index = 2
	elif scene_path == level3_path:
		level_index = 3

	# Set up the new scene based on its type
	if (scene_path == demo_level_path) or (scene_path == level1_path) or  (scene_path == level2_path) or (scene_path == level3_path):
		setup_gameplay_scene()
		setup_victory_screen()
	elif scene_path == main_menu_path:
		setup_main_menu_scene()
	elif scene_path == scoreboard_path:
		setup_scoreboard_scene()

	if debug:
		print("Loaded scene:", scene_path)

# Setup for the gameplay scene
func setup_gameplay_scene():
	if debug:
		print("Setting up gameplay scene")
	
	# Ensure the necessary scene nodes are initialized
	player = current_scene.get_node("Player")
	spawn = current_scene.get_node("SpawnLocation")
	user_interface = current_scene.get_node("UserInterface")
	fade_rect = user_interface.get_node("PlayableUI/DeathFade")
	life_counter_label = user_interface.get_node("PlayableUI/LifeCounter")
	strawberries_container = user_interface.get_node("PlayableUI/StrawberryDisplay")
	level_timer = user_interface.get_node("PlayableUI/TimerLabel/LevelTimer")
	
	if debug:
		print("-------------------\n[LEVEL INFORMATION]\n-------------------")
		print(player)
		print("Spawn:" + str(spawn.transform))
		print(user_interface)
		print("-------------------")

	# Hide the retry screen initially
	user_interface.get_node("Retry").hide()
	if debug:
		print("Hiding retry screen.")
	
	# Connect HIT signal
	if not player.is_connected("hit", Callable(self, "_on_player_hit")):
		player.connect("hit", Callable(self, "_on_player_hit"))
		if debug:
			print("Signal 'hit' connected.")
	else:
		if debug:
			print("Signal 'hit' already connected.")
	
	#Connect WIN signal
	if not player.is_connected("win", Callable(self, "_on_player_win")):
		player.connect("win", Callable(self, "_on_player_win"))
		if debug:
			print("Signal 'win' connected.")
	else:
		if debug:
			print("Signal 'hit' already connected.")
	
	#Set player position to spawn
	player.position = spawn.position
	if debug:
		print("Spawning player at " + str(spawn.position))

	# Reset fade to transparent on startup
	fade_rect.modulate.a = 0.0
	
	# Update the life counter and setup pickups (strawberries)
	update_life_counter()
	clear_strawberries()
	create_strawberries()
	setup_level_timer()

# Setup for the main menu scene
func setup_main_menu_scene():
	if debug:
		print("Setting up main menu scene")
	
	#Ensure the timer reference is nulled out
	level_timer = null
	
	var play_button = current_scene.get_node("ButtonContainer/PlayButton")
	var settings_button = current_scene.get_node("ButtonContainer/SettingsButton")
	var scoreboard_button = current_scene.get_node("ButtonContainer/ScoreboardButton")
	var exit_button = current_scene.get_node("ButtonContainer/ExitButton")
	
	play_button.connect("pressed", Callable(self, "_on_play_pressed"))
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))
	scoreboard_button.connect("pressed", Callable(self, "_on_scoreboard_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))

#Progression logic for 1->2 and 2->3
func load_next_level():
	if current_scene_path == level1_path:
		load_scene(level2_path)
		if debug:
			print("Now loading level 2...")
	elif current_scene_path == level2_path:
		load_scene(level3_path)
		if debug:
			print("Now loading level 3...")
			

func setup_scoreboard_scene():
	if debug:
		print("Setting up scoreboard")
		
	#Ensure the timer reference is nulled out
	level_timer = null 
	
	#Get all of the labels
	var first = current_scene.get_node("ScoreContainer/FirstPlace")
	var second = current_scene.get_node("ScoreContainer/SecondPlace")
	var third = current_scene.get_node("ScoreContainer/ThirdPlace")
	var fourth = current_scene.get_node("ScoreContainer/FourthPlace")
	var fifth = current_scene.get_node("ScoreContainer/FifthPlace")
	var sixth = current_scene.get_node("ScoreContainer/SixthPlace")
	var seventh = current_scene.get_node("ScoreContainer/SeventhPlace")
	var eighth = current_scene.get_node("ScoreContainer/EighthPlace")
	
	#Create a list of the labels for easy iteration
	var labels = [first, second, third, fourth, fifth, sixth, seventh, eighth]
	
	#Load scores
	var scores = load_scores()
	
	#Print the scores that were loaded
	if debug:
		print("Before sorting:")
		for score in scores:
			print(score)
	
	var sorted_scores = manual_sort_scores(scores)
	
	#Print the scores after sorting
	if debug:
		print("After sorting:")
		for score in sorted_scores:
			print(score)

	
	for i in range(min(8, sorted_scores.size())):
		var score = sorted_scores[i] #Get the score
		var label = labels[i] #Get the corresponding label
		
		#Format
		var score_text = "#" + str(i) + "\n"
		score_text += "Time: " + format_time(score["total_time"])
		score_text += "      "
		score_text += "Pickups: " + str(score["total_pickups"])
		
		#Set the label to formatted score
		label.text = score_text
		
		#Center the text
		label.align = 1
		label.valign = 1
	
	var return_button = current_scene.get_node("ReturnButton") #Get the return button
	return_button.connect("pressed", Callable(self,"_on_return_pressed")) #Connect it to the signal
#endregion

#region HELPER FUNCTIONS

#Manual sort because sort_custom wants to misbehave; technically less optimal but I've tried everything for custom_sort
func manual_sort_scores(scores: Array) -> Array:
	var sorted_scores = scores.duplicate()
	for i in range(sorted_scores.size()):
		for j in range(i + 1, sorted_scores.size()):
			var a = sorted_scores[i]
			var b = sorted_scores[j]
			# Compare by pickups first, then by time if pickups are equal
			if a["total_pickups"] < b["total_pickups"] or (a["total_pickups"] == b["total_pickups"] and a["total_time"] > b["total_time"]):
				# Swap the elements
				sorted_scores[i] = b
				sorted_scores[j] = a
	return sorted_scores

# Clear any existing strawberries
func clear_strawberries():
	for child in strawberries_container.get_children():
		child.queue_free()
	collected_count = 0 #Reset the counter

# Create strawberries based on level pickups (modify as needed)
func create_strawberries():
	strawberry_count = 0
	for child in current_scene.get_children():
		if child.is_in_group("pickup"):
			strawberry_count += 1
			child.connect("collected", Callable(self, "_on_pickup_collected"))

	for i in range(strawberry_count):
		var strawberry = TextureRect.new()
		strawberry.texture = preload("res://art/strawberry_outline_tester.png")
		strawberry.scale = Vector2(0.5, 0.5)
		strawberries_container.add_child(strawberry)
		

func setup_level_timer():
	level_start_time = Time.get_ticks_msec() #Get the current time in ticks
	level_elapsed_time = 0.0 #Reset the elapsed timer
	#display setup for timer
	timer_label = user_interface.get_node("PlayableUI/TimerLabel")
	timer_label.text = format_time(level_elapsed_time)
	

func update_life_counter():
	life_counter_label.text = "Lives: " + str(player_lives)

func reload_level():
	if level_index == 0:
		load_scene(demo_level_path)
	elif level_index == 1:
		load_scene(level1_path)
	elif level_index == 2:
		load_scene(level2_path)
	elif level_index == 3:
		load_scene(level3_path)

# Update the HUD with the correct number of pickups
func update_hud_display():
	# Iterate through the total pickups and update the HUD
	for i in range(strawberry_count):
		var strawberry = strawberries_container.get_child(i)
		if strawberry:
			# Set the appropriate texture based on collected_count
			if i < collected_count:
				strawberry.texture = preload("res://art/strawberry_filled_tester.png")
			else:
				strawberry.texture = preload("res://art/strawberry_outline_tester.png")
		else:
			# If we have a missing strawberry (maybe due to an earlier clear), create it
			strawberry = TextureRect.new()
			strawberry.scale = Vector2(0.5, 0.5)
			strawberries_container.add_child(strawberry)

# Handling player death and respawn
func respawn():
	update_life_counter()
	
	if player_lives <= 0:
		user_interface.get_node("PlayableUI").hide()
		user_interface.get_node("Retry").show()
	else:
		user_interface.get_node("Retry").hide()
		user_interface.get_node("PlayableUI").show()
	
	await perform_fade(fade_rect, 1.0, fade_duration)  # Fade to black on death
	
	player.position = spawn.position
	player.dashing = 0
	player.set_control_state(true)
	player.visible = true

	await perform_fade(fade_rect, 0.0, fade_duration)  # Fade back in after respawn

# Fade effect (for death, transitions, etc.)
func perform_fade(fade_rect: ColorRect, target_alpha: float, duration: float):
	var initial_alpha = fade_rect.modulate.a
	var elapsed_time = 0.0
	while elapsed_time < duration:
		var alpha = lerp(initial_alpha, target_alpha, elapsed_time / duration)
		fade_rect.modulate.a = alpha
		elapsed_time += get_process_delta_time()
		await get_tree().create_timer(0.01).timeout
	
	fade_rect.modulate.a = target_alpha  # Ensure the final target alpha is set

# Retry the game logic
func retry_game():
	if player_lives <= 0:
		get_tree().reload_current_scene()  # Reload the current scene if out of lives
	else:
		respawn()

# Toggle pause menu (could probably be moved to player.gd)
func toggle_pause():
	user_interface.get_node("PauseScreen").toggle_pause()
	level_timer.paused = not level_timer.paused

#Format a time float into a string for saving
func format_time(time_in_seconds: float) -> String:
	var minutes = int(time_in_seconds / 60)
	var seconds = int(fmod(time_in_seconds,60))
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

func current_level_is_last() -> bool:
	return current_scene_path == final_level_path

func end_game():
	save_final_score() #Save the data to a file
	show_victory_screen()
	
func save_final_score():
	var executable_path = OS.get_executable_path()
	var executable_dir = executable_path.get_base_dir()
	var save_directory = executable_dir + "/Saves/"
	var score_file_path = save_directory + "scores.json"

	# Ensure the "Saves" directory exists or create it
	var dir = DirAccess.open(executable_dir)
	if dir == null:
		print("Failed to open directory: ", executable_dir)
		return

	if not dir.dir_exists(save_directory):
		var create_result = dir.make_dir(save_directory)
		if create_result != OK:
			print("Failed to create directory: ", save_directory)
			return

	# Load the existing scores or create an empty dictionary if no scores exist
	var scores = load_scores()

	# Create the new score entry
	var new_score = {
		"total_time": total_time,
		"total_pickups": collected_count
	}

	# Use a unique key for each score entry (e.g., based on time or level)
	var score_key = str(total_pickups) + "_" + str(total_time)

	# Add the new score entry to the dictionary using the unique key
	scores.append(new_score) # This adds the new score, ensuring it's not overwritten

	# Debugging: Check the scores dictionary after adding the new score
	print("Scores after adding new score: ", scores)

	# Write the updated scores back to the file
	var file_to_write = FileAccess.open(score_file_path, FileAccess.WRITE)
	if file_to_write:
		var json_to_save = JSON.new()
		var json_data = json_to_save.stringify(scores)  # Store the entire dictionary of scores
		file_to_write.store_string(json_data)
		file_to_write.close()

	print("Score saved and updated.")
	
func load_scores() -> Array:
	var executable_path = OS.get_executable_path()
	var executable_dir = executable_path.get_base_dir()
	var save_directory = executable_dir + "/Saves/"
	var score_file_path = save_directory + "scores.json"
	
	# Check if the file exists
	if not FileAccess.file_exists(score_file_path):
		print("No scores file found, creating a new one.")
		return []  # Return an empty array if no file exists

	var file = FileAccess.open(score_file_path, FileAccess.READ)
	var scores = []
	
	if file:
		var json = JSON.new()
		var file_content = file.get_as_text()
		var parse_result = json.parse(file_content)
		
		if parse_result == OK:
			var data = json.get_data()
			if data is Array:
				scores = data  # Load existing scores into the array
			else:
				print("Invalid format in scores file. Resetting to an empty array.")
				scores = []  # Reset if the format is incorrect
		else:
			print("Failed to parse JSON. Resetting to an empty array.")
			scores = []  # Reset if JSON parsing fails
		
		file.close()

	return scores


func _sort_scores(a, b):
	# Ensure the values are treated as numbers
	var pickups_a = int(a["total_pickups"])
	var pickups_b = int(b["total_pickups"])
	var time_a = float(a["total_time"])
	var time_b = float(b["total_time"])

	# First, compare by total_pickups (descending)
	if pickups_a > pickups_b:
		return -1  # 'a' is better, keep 'a' first
	elif pickups_a < pickups_b:
		return 1  # 'b' is better, keep 'b' first

	# If total_pickups are the same, compare by total_time (ascending)
	if time_a < time_b:
		return -1  # 'a' is better, keep 'a' first
	elif time_a > time_b:
		return 1  # 'b' is better, keep 'b' first

	return 0  # If they are equal, maintain the order



func setup_victory_screen():
	#Find the relevant nodes
	victory_screen = user_interface.get_node("VictoryScreen")
	victory_label = user_interface.get_node("VictoryScreen/ScoreDisplay")
	victory_background = user_interface.get_node("VictoryScreen/Background")
	
	#Clear the visibility initially
	victory_screen.visible = false
	victory_background.visible = false
	victory_label.text = ""
	
func show_victory_screen():
	var victory_message = "Victory\n" #Prepare the victory message
	victory_message += "Total Time: " + format_time(total_time) + "\n"
	victory_message += "Pickups Collected: " + str(collected_count)
	
	#Display the screen with it's results
	victory_label.text = victory_message
	victory_screen.visible = true
	victory_background.visible = true

	#Disable input handling until after the user pressesenter
	set_process_input(true)
	
func set_player_lives(new_lives:int):
	player_lives = new_lives
#endregion

#region SIGNALS
# Handling player hit (death)
func _on_player_hit() -> void:
	player_lives -= 1
	player.visible = false
	player.set_control_state(false)
	
	if player_lives > 0:
		respawn()
	else:
		user_interface.get_node("PlayableUI").hide()
		user_interface.get_node("Retry").show()

func _on_player_win() -> void:
	level_timer.stop() #Stop the timer
	
	if debug:
		print("Player has entered the win zone.")
	
	total_time += level_elapsed_time
	total_pickups += collected_count
	
	if debug:
		print(total_time)
		print(total_pickups)
	
	#Determine procession
	if current_level_is_last():
		if debug:
			print("That was the last level, ending game...")
		end_game() #End the game
	else:
		load_next_level()
		if debug:
			print("Level cleared. Loading next level...")

func _on_pickup_collected():
	collected_count += 1 #Increment the collected value by 1
	update_hud_display()

# Function to handle play button press from the main menu
func _on_play_pressed():
	load_scene("res://scenes/levels/DemoTestingLevel.tscn")  # Load the gameplay level when play is pressed

# Function to handle settings button press from the main menu
func _on_settings_pressed():
	if debug:
		print("Settings button pressed.")
	# Implement settings logic here

# Function to handle scoreboard button press from the main menu
func _on_scoreboard_pressed():
	if debug:
		print("Scoreboard button pressed.")
	# Implement scoreboard logic here
	load_scene(scoreboard_path)
	
# Function to handle exit button press from the main menu
func _on_exit_pressed():
	if debug:
		print("Exit button pressed.")
	get_tree().quit()  # Exit the game when exit is pressed

func _on_return_pressed():
	if debug:
		print("Return button pressed.")
	load_scene(main_menu_path) #Return to the main menu

func _on_timer_timeout():
	level_elapsed_time = Time.get_ticks_msec() / 1000.0 - level_start_time
	timer_label.text = str(format_time(level_elapsed_time))
#endregion

#region EVENTS
# Handle input (pause, retry, etc.)
func _input(event):
	if user_interface:
		# Check for pause menu input
		if event.is_action_pressed("pause"):
			toggle_pause()

		# Check if victory screen is visible and enter is pressed
		if victory_screen and victory_screen.visible and event.is_action_pressed("ui_accept"):
			if debug:
				print("Player pressed Enter, going back to main menu.")
			victory_screen.visible = false  # Hide the victory screen
			load_scene(main_menu_path)  # Go to the main menu
#endregion
