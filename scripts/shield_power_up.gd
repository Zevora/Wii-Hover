extends Node

# Check if the player collides with this

# Provide the player with the ability to take an extra hit which could be emulated by increasing the timer during the kill confirmation duration when shielded
# So while this is active, death does not happen within the default collision_duration (of 0.25 in the player script)
# Increase it to 10 seconds for 5 seconds then back to .25.

var new_collision_duration = 5
var powerup_duration = 3

# Check if collides with player and remove the powerup from the ground
func _on_body_entered(body):
	if body is CharacterBody3D and body.has_method("apply_shield_power_up"):
		print("shield collided")
		body.apply_shield_power_up(new_collision_duration, powerup_duration)
		queue_free()  # Remove power-up after activation
