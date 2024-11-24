extends Area3D

func _on_body_entered(body):
	#print("Body has been triggered") # Replace with function body.
	if body.name == "Player":
		#print("body is player")
		var game_manager = get_node("/root/Level 1/GameManager")
		if game_manager:
			#print(game_manager.name)
#			pass in the transform so that the function it calls has the location to where to spawn the rocks
			game_manager.spawn_environment(global_transform)
		else:
			print("GameManger node not found!")
		#game_manager.spawn_rock()
