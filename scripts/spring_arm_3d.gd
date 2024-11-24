extends SpringArm3D

@export var player: Node3D
@export var camera_distance: float = -1.5  # Distance from the player
@export var camera_height: float = 2.0     # Height above the player
@export var follow_speed: float = 5.0      # Speed of the camera following the player
@export var rotation_speed: float = 3.0    # Speed of rotating the camera with the player

var camera: Camera3D

func _ready():
	# Find the camera
	camera = $Camera3D
	
	# Set the initial camera position and rotation
	global_transform.origin = player.global_transform.origin - player.global_transform.basis.z * camera_distance
	global_transform.origin.y += camera_height

	# Make the camera look at the player
	look_at(player.global_transform.origin, Vector3.UP)

func _process(delta):
	# Update the camera position smoothly
	var target_position = player.global_transform.origin - player.global_transform.basis.z * camera_distance
	target_position.y += camera_height
	
	global_transform.origin = global_transform.origin.lerp(target_position, follow_speed * delta)
	
	# Camera rotation
	var player_forward = player.global_transform.basis.z
	var desired_rotation = Quaternion(Vector3.UP, atan2(player_forward.x, player_forward.z))
	global_transform.basis = Basis(global_transform.basis.get_rotation_quaternion().slerp(desired_rotation, rotation_speed * delta))

	# Look at the player
	look_at(player.global_transform.origin + Vector3(0,1.7,0), Vector3.UP)
