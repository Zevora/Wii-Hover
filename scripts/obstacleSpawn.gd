extends Node3D

#TODO: Obstacles are spawning at 0.0.0

# Variables
@export var spawn_distance: float = 15.0  # Distance ahead of the player to spawn rocks
@export var spawn_interval: float = 0.5  # Time in seconds between spawns
@export var rocks_folder: String = "res://assets/rocks/"  # Path to the folder containing GLTF models

var player: Node3D  # Reference to the player
var rock_files: Array[String] = []
var spawn_timer: float = 0.0

# Load all GLTF files on ready
func _ready():
	#player = get_parent()  # Adjust the path to your player node
	player = $"../Player"
	if player == null:
		print("Error: Player node not found!")
	print(player)
	rock_files = load_rock_files()
	print("Loaded rock files: ", rock_files)
	spawn_timer = 0.0

# Load all .glb or .gltf files in the specified folder
func load_rock_files() -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(rocks_folder)
	
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".glb") or file_name.ends_with(".gltf"):
				files.append(rocks_folder + file_name)
	return files

# Process spawner logic
func _process(delta: float):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_rock()
		spawn_timer = 0.0

# Spawn a random rock ahead of the player
func spawn_rock():
	if rock_files.size() > 0 and player:
		print("Spawning rock...")

		var random_file = rock_files[randi() % rock_files.size()]
		
		# Load the GLTF file as a PackedScene
		var gltf_scene = ResourceLoader.load(random_file, "PackedScene") as PackedScene
		
		if not gltf_scene:
			print("Error loading GLTF file: ", random_file)
			return
		
		# Instantiate the GLTF scene
		var instance = gltf_scene.instantiate() as Node3D
		
		if instance:
			# Calculate spawn position ahead of the player
			var spawn_position = player.global_transform.origin
			spawn_position -= player.global_transform.basis.z * spawn_distance
			print("spawn position", spawn_position)

			# Adjust spawn position as needed (e.g., for ground alignment)
			spawn_position.y = 0.0  # Assuming the ground is at y = 0

			# Set instance position and add it to the scene
			instance.global_transform.origin = spawn_position
			add_child(instance)
		else:
			print("Error: Failed to instantiate scene from GLTF file.")
	else:
		print("Error: rock_files array is empty or player node is null")
