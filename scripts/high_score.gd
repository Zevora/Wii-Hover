extends Label

var high_score_label: Label

func _ready():
	# Get the reference to the Label node (assuming it is a direct child of the Control node)
	high_score_label = $"."
	load_highscore()

func load_highscore():
	var leaderboard_file = FileAccess.open("user://leaderboard.txt", FileAccess.READ)
	if leaderboard_file:
		if leaderboard_file.get_length() > 0:
			while not leaderboard_file.eof_reached():
				var line = leaderboard_file.get_line().strip_edges()
				if line != "":
					leaderboard_file.close()
					high_score_label.text = "High Score: %d meters" % int(line)
					return int(line)
		
		leaderboard_file.close()
	return -1 # Default if no score found
			#var high_score = leaderboard_file.get_as_text()
			#leaderboard_file.close()
			#print("High score loaded: ", high_score)
			#return high_score
	
