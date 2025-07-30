extends Control

@export var spacing := 300                      # Distance between items
@export var smoothing := 8.0                    # Smoothing speed
var selected_index := 0                         # Currently selected item

@onready var position_offset := $PositionOffset

func _ready():
	update_item_positions(true)

func _process(delta):
	update_item_positions(false, delta)

func update_item_positions(immediate := false, delta := 0.0):
	var center_x := size.x / 2
	var count := position_offset.get_child_count()

	for i in count:
		var child := position_offset.get_child(i)
		if not child.visible: continue
		
		var offset := (i - selected_index) * spacing
		var target_x: float = center_x + offset - (child.size.x / 2)
		var current_pos: Vector2 = child.position
		
		if immediate:
			child.position.x = target_x
		else:
			child.position.x = lerp(current_pos.x, target_x, delta * smoothing)

func _input(event):
	if event.is_action_pressed("ui_right"):
		selected_index += 1
	elif event.is_action_pressed("ui_left"):
		selected_index -= 1

	selected_index = clamp(selected_index, 0, position_offset.get_child_count() - 1)
