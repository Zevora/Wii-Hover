extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 40
var original_speed = 40
#@export var boosted_speed = 12 # Speed when boosted
#@export var boost_duration =3.0 # How long the boost lasts in seconds

var is_boosted = false
var boost_timer = 0.0

signal died
@export var died_signal_emitted: bool = false

# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

var max_lean_angle: float = 0.2 #the maximum angle the character can lean
var lean_speed: float = 2.0 # Speed at which teh character will lean
var lean_reset_speed: float = 4.0 #Speed to reset back to upright
var lean_amount: float = 0.0 # Current lean rotation

# The time the player has been colliding with an obstacle
var collision_time: float = 0.0
# Max duration of the current collision before death
var collision_duration = 0.25
var original_collision_duration = collision_duration

# Layer mask for crashables (CRASHABLES ARE ON LAYER 2)
const crashable_layer = 1 << 1 # 1 << 1 results in 0000...0010 (which is Layer 2)


func _physics_process(delta):
	if is_boosted:
		boost_timer -= delta
		if boost_timer <= 0:
			speed = original_speed # Reset speed afterboost ends
			is_boosted = false
	print("constant speed: ",speed)
		
	# get pause input
	#if Input.is_action_pressed("pause"):
		#$"../GameManager".on_esc()
	
	# input direction using action strength
	var input_strength = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	#Move the character based on the input strength (joystick or keyboard)
	var direction = Vector3(input_strength, 0, -1).normalized() * speed * delta
	
	# Move the cahracter
	if direction.length() > 0:
		move_and_slide()
	
	var target_lean = 0.0 # Current lean angle
	target_lean = -sign(direction.x) * max_lean_angle
	
	# Smoothly interpoolate the lean towards the 
	lean_amount = lerp(lean_amount, target_lean, lean_speed * delta)
	
	# rotate the character along the Z axis
	rotation.z = lean_amount
	
	# Reset lean when no input is detected
	if target_lean == 0.0:
		lean_amount = lerp(lean_amount, 0.0, lean_reset_speed * delta)
	
	# normalizing combining inputs
	if direction != Vector3.ZERO: 	# if movement is not 0 / if there is some movement
		direction = direction. normalized()
		# Setting the basis property will affect the rotation of the node.f
		#$Pivot.basis = Basis.looking_at(direction)
	
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards teh floor. Gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	# Moving the character 
	velocity = target_velocity
	#move_and_slide()
	
#	Check for collision with crashable object
	if is_colliding_with_crashable():
		collision_time += delta
	else:
		collision_time = 0.0
		
	# If collsision time exceedsd 2 seconds, trigger the "died" signal
	if (collision_time >= collision_duration) and !died_signal_emitted:
		print("Player collided with crashable for %0.25f seconds!" % collision_duration)
		emit_signal("died")
		died_signal_emitted = true

func is_colliding_with_crashable() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() and collision.get_collider().collision_layer & crashable_layer != 0:
			return true
	return false
	
func is_colliding_with_powerup() -> bool:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() and collision.get_collider().is_in_group("powerups"):
			return true
	return false

func apply_speed_boost(boosted_speed: float, boost_duration: float):
	if !is_boosted:
		speed = boosted_speed
		is_boosted = true
		boost_timer = boost_duration
		print("Speed Boost Activated!")
		
func apply_slow_mo():
	Engine.time_scale = 0.5 # Set game speed to x0.75
	await get_tree().create_timer(2.0, false).timeout #Wait for 2 seconds (Which will feel longer as the 2 seconds are counted slower?)
	Engine.time_scale = 1.0 # Reset to normal speed
	print("Slow Motion Activated!")
	
func apply_shield_power_up(new_collision_duration: float, powerup_duration: float):
		collision_duration = new_collision_duration
		print("Shield Active")
		#Timer to calculate powerup duration
		await get_tree().create_timer(powerup_duration).timeout
		#after powerup_duration, disable the shield
		collision_duration = original_collision_duration
		
