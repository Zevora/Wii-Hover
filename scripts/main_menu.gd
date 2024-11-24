extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/test_level_with_astro.tscn")


func _on_options_button_pressed():
	pass # Replace with function body.
	# can just pop up a modal to change the options
	



func _on_quit_button_pressed():
	pass # Replace with function body.
	# Close the game
	get_tree().quit()
