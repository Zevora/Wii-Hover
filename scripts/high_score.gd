extends Label

func load_highscore():
	var leaderboard_file = FileAccess.open("user://original_leaderboard.txt", FileAccess.READ)
	if leaderboard_file:
		if leaderboard_file.get_length() > 0:
			var high_score = leaderboard_file.get_as_text()
			leaderboard_file.close()
			print("High score loaded: ", high_score)
			return high_score
