extends Node3D

@export var boosted_speed: float = 70.0
@export var boost_duration: float = 3.0

# Check if collides with player and remove the powerup from the ground
func _on_body_entered(body):
	if body is CharacterBody3D and body.has_method("apply_speed_boost"):
		print("speed_boost collided")
		body.apply_speed_boost(boosted_speed, boost_duration)
		queue_free()  # Remove power-up after activation
