extends Node

# Check if collides with player

# Give slow motion to player for 3 seconds
func _on_body_entered(body):
	if body is CharacterBody3D and body.has_method("apply_slow_mo"):
		print("slow_mo collided")
		body.apply_slow_mo()
		queue_free()  # Remove power-up after activation
