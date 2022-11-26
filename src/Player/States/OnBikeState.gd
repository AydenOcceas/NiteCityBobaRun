extends PlayerState

#constant vars
export var max_speed: = 10.0
export var move_speed: = 2.0
export var side_tilt_percentage: = 0.3
export var turn_speed: = 1.0
export var drag: = 0.05
export var gravity: = -80.0
export var jump_impulse: = 25.0

export var engine_pitch_max: = 2.0
export var engine_pitch_min: = 1.0
export var engine_pitch_ramp: = 0.05

var velocity: = Vector3.ZERO
var spin: = 0.0

func unhandled_input(event):
	if event.is_action_pressed("jump"):
		_state_machine.transition_to("OnBike/Air", { velocity = velocity, jump_impulse = jump_impulse})
	


#per tick
func physics_process(delta):
	# Gets character's tilt direction based on input (global)
	var input_tilt_direction: = get_input_tilt_direction()
	
	# puts the input data in relation to the player's forward vector
	var forwards: Vector3 = player.global_transform.basis.z * input_tilt_direction.z
	# puts the input data in relation to the player's sideways vector
	var right: Vector3 = player.global_transform.basis.x * input_tilt_direction.x * side_tilt_percentage
	var tilt_direction: = forwards + right
	if tilt_direction.length() > 1.0:
		tilt_direction = tilt_direction.normalized()
	tilt_direction.y = 0.0
	
	
	# Gets character's tilt direction based on input
	var input_turn_direction: = get_input_turn_direction()
	var turn_direction: = input_turn_direction * turn_speed
	
	
	# if turn direction is not 0 rotate the player around it's origin
	if _state_machine.state == _state_machine.get_node("OnBike"):
		if turn_direction:
			player.rotate(Vector3.UP, turn_direction * delta)
	
	# only considers player input in velocity calculation if player is not in Air State
	if !get_input_tilt_direction().length():
		player.get_node("EngineNoise").set_pitch_scale(max(
			engine_pitch_min,
			player.get_node("EngineNoise").get_pitch_scale() - engine_pitch_ramp * 2))
	
	if _state_machine.state == _state_machine.get_node("OnBike"):
		player.get_node("EngineNoise").set_pitch_scale(min(
			engine_pitch_max, 
			player.get_node("EngineNoise").get_pitch_scale() + get_input_tilt_direction().length() * engine_pitch_ramp))
		velocity = calculate_velocity(velocity, tilt_direction)
	else:
		velocity = calculate_velocity(velocity, Vector3.ZERO)
	#automatically multiplies by delta
	velocity = player.move_and_slide(velocity, Vector3.UP)


static func get_input_tilt_direction() -> Vector3:
	return Vector3(
			# X axis inputs
			Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
			0.0,
			# Y axis inputs
			Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
		)

# Turning left and right inputs
static func get_input_turn_direction() -> float:
	return Input.get_action_strength("turn_left") - Input.get_action_strength("turn_right")

func calculate_velocity(
		velocity_current: Vector3,
		move_direction: Vector3
	) -> Vector3:
		var velocity_new: = velocity_current
		#sets the velocity to velocity - drag or zero as to not bring the motorcycle back
		if player.is_on_floor():
			velocity_current = velocity_current.normalized() * max(velocity_current.length() - drag, 0)

		velocity_new = (move_direction * move_speed) + velocity_current
		if velocity_new.length() > max_speed:
			velocity_new = velocity_new.normalized() * max_speed
		velocity_new.y = velocity_current.y + gravity

		return velocity_new
