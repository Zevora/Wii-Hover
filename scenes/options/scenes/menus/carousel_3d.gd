extends Node3D

@export var spacing := 4.0
@export var smoothing := 5.0
var selected_index := 0

# direction and amount the model rotates (hoverboard in this case)
var axis = Vector3.UP
var rotation_amount = 0.001

func _ready():
	# Instantly set correct positions to prevent snapping/movement
	for i in get_child_count():
		# the children are the hoverboard
		var child = get_child(i)
		# sets chold.position to 0.0.0 in the world space
		child.position = Vector3((i - selected_index) * spacing, 0, 0)
		
		
func _process(delta):
	# Smoothly interpolate toward target positions
	for i in get_child_count():
		var child = get_child(i)
		var target_pos = Vector3((i - selected_index) * spacing, 0, 0)
		child.position = child.position.lerp(target_pos, delta * smoothing)
		# Rotate the transform around the X axis by 0.001 radians.
		get_child(selected_index).transform.basis = Basis(axis, rotation_amount) * get_child(selected_index).transform.basis
	
func _input(event):
	if event.is_action_pressed("ui_right"):
		# moves up the array to the next item
		selected_index = min(get_child_count() - 1, selected_index + 1)
	elif event.is_action_pressed("ui_left"):
		# moves down the array to the previous item
		selected_index = max(0, selected_index - 1)
