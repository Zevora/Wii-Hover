extends Node3D

@export var rocks_folder: String = "res://assets/rocks/"  # Path to the folder containing GLTF models
@export var spawn_distance: float = 50.0 # Distance ahead of the spawner (which is currently a checkpoint)
@export var max_environments: int = 7 # max number of environments at 1 time

var rock_files: Array[String] = []
var environment_preload = preload("res://scenes/environment_with_spawn.tscn")
var environment_queue: Array[Node] = [] # array of active environments
#var environment_instance: Node = null # Store the currently loaded environment

var speed_boost_powerup = preload("res://scenes/arrow_2.tscn")
#var shield_powerup = preload()
#var slow_mo_powerup = preload()

@onready var pause_menu = $"../InfoModal"

# Load all GLTF files on ready
func _ready():
	# player node
	var player = %Player
	player.connect("died", $"../GameManager".on_player_died)
	
	#Ensure the pause menu keeps working during the pause
	process_mode = Node.PROCESS_MODE_ALWAYS # KEEP : What makes the pause able to unpause
	#pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	#$"../InfoModal/VBoxContainer".pause_mode = Node.PROCESS_MODE_ALWAYS
	#$"../InfoModal/VBoxContainer/RetryButton".pause_mode = Node.PROCESS_MODE_ALWAYS
	#$"../InfoModal/VBoxContainer/ExitButton".pause_mode = Node.PROCESS_MODE_ALWAYS
 
	#self.visible = false # Hide the pause menu initially
	
	$"../InfoModal/VBoxContainer/RetryButton".connect("pressed", Callable(self, "_on_retry_button_pressed"))
	$"../InfoModal/VBoxContainer/ExitButton".connect("pressed", Callable(self, "_on_exit_button_pressed"))
	
	rock_files = load_rock_files()
	print("Loaded rock files: ", rock_files)
	
	var start_position = Transform3D(Basis(), Vector3(0, 0, 0))
	
	print("Printing the first 5 environments")
	for i in range(5):
	# Spawn the first ground at origin
		spawn_environment(start_position)
		start_position.origin.z -= 100 # subtract another 100 units on z
	# Load all .glb or .gltf files in the specified folder
func load_rock_files() -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(rocks_folder)
	
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
				files.append(rocks_folder + file_name)
	return files
	
func _process(_delta):
	if Input.is_action_just_pressed("pause") and !(%Player.died_signal_emitted):
		print("Pause_toggled")
		toggle_pause()

func spawn_rock(current_location: Transform3D):
	print("Beginning to spawn rocks")
	if rock_files.size() > 0:
		for row in range(5):
			for col in range (5):
				var random_file = rock_files[randi() % rock_files.size()]
				
				# Load the GLTF file as a PackedScene
				var gltf_scene = ResourceLoader.load(random_file, "PackedScene") as PackedScene
				
				if not gltf_scene:
					print("Error loading GLTF file: ", random_file)
					return
				
				# Instantiate the GLTF scene
				var instance = gltf_scene.instantiate() as Node3D
				
				if instance:
					#add the instance first before manipulating
					add_child(instance)
					
					# Calculate spawn position for each rock
					var spawn_position = current_location.origin
					
					# Adjust the z position for rows and x position for columns
					#spawn_position -= current_location.basis.z * (spawn_distance + (row * 20)) # Basis is 1 and we are specifying it is in the z direction
					spawn_position -= current_location.basis.z * (spawn_distance + (row * randi_range(10, 30))) # Basis is 1 and we are specifying it is in the z direction with z randomness
					#spawn_position += current_location.basis.x * ((col * randi_range(10, 30)) - 50) # So here it would be x basis which would be 1 times a random value between -35 and 35
					spawn_position += current_location.basis.x * ((randi_range(-7, 7) * 5) - 20) # rocks can spawn in a range of -35 to 35 x
					#print("spawn position", spawn_position) #printing the spawning of each rock

					# Adjust spawn position as needed (e.g., for ground alignment)
					spawn_position.y = 1  # Assuming the ground is at y = 0
				
					instance.global_transform.origin = spawn_position
					instance.scale *= 10

				else:
					print("Error: Failed to instantiate scene from GLTF file.")
	else:
		print("Error: rock_files array is empty or player node is null")

func spawn_environment(current_location: Transform3D):
	print("Spawning the environment")
	
	# Instance the new environment
	var new_environment_instance = environment_preload.instantiate()  # Instantiate the PackedScene

	if new_environment_instance:
		
		add_child(new_environment_instance)  # Add the instance to the scene tree
		
		# Set the position of the new environment
		var new_transform = current_location
		if environment_queue.size() > 0:
			var last_environment = environment_queue.back()
			new_transform.origin = last_environment.global_transform.origin
			new_transform.origin.z -= 100
		new_transform.origin.y = 0 #manually set to y of 0
		
		#set the transforms to the new spawned environment
		new_environment_instance.global_transform = new_transform
		print("New environment spawned at position: ", new_transform.origin)
		
		# Add the new environment to the queue/array
		environment_queue.append(new_environment_instance)
		
		# If there are more than max_environments, remove the oldest one
		if environment_queue.size() > max_environments:
			var oldest_environment = environment_queue.pop_front()
			if oldest_environment:
				oldest_environment.queue_free() # Remove it from the scene safely once it has been popped
				print("Oldest environment deleted")
				
				# Call to spawn the powerups
		var powerup_spawner = randi() % 4
		if powerup_spawner == 1:
			spawn_powerup(new_transform)

		# Call to spawn the rocks ahead of the environment
		spawn_rock(new_environment_instance.global_transform)
	else:
		print("Error: Failed to instance environment scene.")
	


# function to spawn in powerups
func spawn_powerup(current_location: Transform3D):
	if  not speed_boost_powerup:
		print("Error: Failed to load arrow_2.tscn")
		return
		
	var powerup_instance = speed_boost_powerup.instantiate() as Node3D
	
	if powerup_instance:
		add_child(powerup_instance) # Add to scene tree
		
		# set random position within the nerw environment
		var powerup_position = current_location.origin
		powerup_position.x += randi_range(-20, 20) # Random X position
		powerup_position.y = .75 # Slightly above ground to be visible
		
		powerup_instance.global_transform.origin = powerup_position
		print("Powerup spawned at: ", powerup_position)
	else:
		print("Error: failed to instantiate powerup")
	

# function for when the player dies to show a modal with score / highscore / retry / exit
func on_player_died():
	print("Player has died")
	# Pause the game
	get_tree().paused = true
	
	# Toggle visibility of the UI
	pause_menu.visible = true
	
	# Handle saving the final score to the leaderboard file
	handle_final_score($"../Control".distance)
	$"../InfoModal/VBoxContainer/HighScore".load_highscore()
	
func toggle_pause():
	get_tree().paused = !get_tree().paused
	pause_menu.visible = get_tree().paused
	$"../InfoModal/VBoxContainer/HighScore".load_highscore()
	print("Game paused: ", get_tree().paused)

func handle_final_score(score):
	var hold = false
	if hold:
		var leaderboard_file = FileAccess.open("user://leaderboard.dat", FileAccess.WRITE)
		leaderboard_file.store_64(score)
		leaderboard_file.close()
		print("High score saved: ", score)
	
func _on_retry_button_pressed():
	print("retry button pressed")
	if get_tree().paused:
		get_tree().paused = false
		get_tree().reload_current_scene()
		
func _on_exit_button_pressed():
		get_tree().quit()
