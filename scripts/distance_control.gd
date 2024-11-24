extends Control

# Reference to the player node (drag and drop in the editor or assign programmatically)
@export var player: Node3D

# Starting position (optional: this could be a fixed point or the player's starting point)
var start_position: Vector3 = Vector3.ZERO

# Reference to the Label node
var distance_label: Label

@export var distance: int

func _ready():
	# Get the reference to the Label node (assuming it is a direct child of the Control node)
	distance_label = $Label
	
	# (Optional) Set start position as player's initial position
	start_position = player.global_transform.origin

func _process(_delta: float):
	if player:
		# Calculate distance from the start position to the player's current position
		distance = player.global_transform.origin.distance_to(start_position)
		
		# Update the Label text to show the distance (formatted to 2 decimal places)
		distance_label.text = "Distance: %.f meters" % distance
