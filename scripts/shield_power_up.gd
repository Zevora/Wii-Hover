extends Node

# Check if the player collides with this

# Provide the player with the ability to take an extra hit which could be emulated by increasing the timer during the kill confirmation duration when shielded
# So while this is active, death does not happen within the default collision_duration (of 0.25 in the player script)
# Increase it to 1 second.
