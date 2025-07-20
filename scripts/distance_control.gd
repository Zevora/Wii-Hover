extends Control

# Reference to the player node (drag and drop in the editor or assign programmatically)
@export var player: Node3D

# Starting position (optional: this could be a fixed point or the player's starting point)
var start_position: Vector3 = Vector3.ZERO

# Reference to the Label node
var distance_label: Label
var next_high_score_label: Label

@export var distance: int

func _ready():
	# Get the reference to the Label node (assuming it is a direct child of the Control node)
	distance_label = $Distance
	next_high_score_label = $NextHighScore
	
	# (Optional) Set start position as player's initial position
	start_position = player.global_transform.origin

func _process(_delta: float):
	if player:
		# Calculate distance from the start position to the player's current position
		distance = player.global_transform.origin.distance_to(start_position)
		
		# Update the Label text to show the distance (formatted to 2 decimal places)
		distance_label.text = "Distance: %.f meters" % distance
		
		update_next_high_score()
		
func get_distance() -> int:
	print("Got the distance: ", distance)
	return distance
		
func update_next_high_score():
	var leaderboard_path = "user://leaderboard.txt"
	
	if FileAccess.file_exists(leaderboard_path):
		var file = FileAccess.open(leaderboard_path, FileAccess.READ)
		# array of the values saved here
		var scores: Array[int] = []
		
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "":
				var score = int(line)
				scores.append(score)
		
		file.close()

		scores.sort() # Ensure scores are sorted in ascending order

		# Find the next greater score
		for score in scores:
			if score > distance:
				next_high_score_label.text = "Next High Score: %d meters" % score
				return

		# If no greater score found
		next_high_score_label.text = "Next High Score: %d meters" % distance
	else:
		next_high_score_label.text = "Leaderboard not found"
