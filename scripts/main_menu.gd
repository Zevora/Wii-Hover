extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()
	ensure_leaderboard_exists()
	load_leaderboard()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/test_level_with_astro.tscn")
	
func _on_customization_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options/scenes/menus/Carousel3D.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options/scenes/menus/options_menu/master_options_menu_with_tabs.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func load_leaderboard():
	var leaderboard_path = "user://leaderboard.txt"
	var leaderboard_container = $ScrollContainer/VBoxContainer
	#leaderboard_container.clear() # Make sure that the leaderboard is has no old entries
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	if FileAccess.file_exists(leaderboard_path):
		var file = FileAccess.open(leaderboard_path, FileAccess.READ)
		var  rank = 1
		
		while not file.eof_reached():
			var score = file.get_line()
			print("Line read from file: ", score)
			if score == "":
				continue
			var label = Label.new()
			label.text = str(rank) + ". " + score
			label.add_theme_color_override("font_color", Color.WHITE)
			leaderboard_container.add_child(label)
			rank += 1
			
		file.close()
	else:
		print("Leaderboard file not found at: ", leaderboard_path)

func ensure_leaderboard_exists():
	var source_path = "user://original_leaderboard.txt"
	var target_path = "user://leaderboard.txt"
	
	if not FileAccess.file_exists(target_path):
		if FileAccess.file_exists(source_path):
			var source_file = FileAccess.open(source_path, FileAccess.READ)
			var target_file = FileAccess.open(target_path, FileAccess.WRITE)
			
			while not source_file.eof_reached():
				var line = source_file.get_line()
				target_file.store_line(line)
				
			source_file.close()
			target_file.close()
			print("Leaderboard copied from original")
		else:
			print("Original leaderboard not found at: ", source_path)
	print("Done ensuring the leaderboard exists")
