extends PlayerState

var velocity: = Vector3.ZERO
var game_manager: GameManager
var respawn_manager: RespawnManager

export var spin_speed: float
export var landing_tilt_threshold: float

var rotation_count_x: float
var rotation_count_y: float
var rotation_count_z: float

var rotating_x: bool
var rotating_y: bool
var rotating_z: bool


func _ready():
	yield(owner, "ready")
	game_manager = get_tree().root.get_node("Game/GameManager")
	respawn_manager = get_tree().root.get_node("Game/RespawnManager")

func physics_process(delta):
	_parent.physics_process(delta)
	velocity = _parent.velocity
	
	# Prioritized current movement and restricts player to one axis of movement
	if rotating_x && get_input_direction("move_forward", "move_back"):
		player.rotate(
		player.get_global_transform().basis.x, 
		get_input_direction("move_forward", "move_back") * spin_speed
		)
		rotation_count_x += get_input_direction("move_forward", "move_back") * spin_speed
	elif rotating_y && get_input_direction("move_left", "move_right"):
		player.rotate(
		-player.get_global_transform().basis.z, 
		get_input_direction("move_left", "move_right") * spin_speed
		)
		rotation_count_y += get_input_direction("move_left", "move_right") * spin_speed
	elif rotating_z && get_input_direction("turn_left", "turn_right"):
		player.rotate(
		player.get_global_transform().basis.y, 
		get_input_direction("turn_left", "turn_right") * spin_speed
		)
		rotation_count_z += get_input_direction("turn_left", "turn_right") * spin_speed
	else:
		#if the player is not moving in the same direction they were moving then get the new direction they're moving
		rotating_x = false
		rotating_y = false
		rotating_z = false
		if get_input_direction("move_forward", "move_back"):
			player.rotate(
			player.get_global_transform().basis.x, 
			get_input_direction("move_forward", "move_back") * spin_speed
			)
			rotation_count_x += get_input_direction("move_forward", "move_back") * spin_speed
			rotating_x = true
		elif get_input_direction("move_left", "move_right"):
			player.rotate(
			-player.get_global_transform().basis.z, 
			get_input_direction("move_left", "move_right") * spin_speed
			)
			rotation_count_y += get_input_direction("move_left", "move_right") * spin_speed
			rotating_y = true
		else:
			player.rotate(
			player.get_global_transform().basis.y, 
			get_input_direction("turn_left", "turn_right") * spin_speed
			)
			rotation_count_z += get_input_direction("turn_left", "turn_right") * spin_speed
			rotating_z = true
			
	
	#
	#TRICK CALLS
	#
	
	if rotation_count_x >= 2 * PI:
		rotation_count_x = 0
		game_manager.trick("front_flip")

	if rotation_count_x <= -2 * PI:
		rotation_count_x = 0
		game_manager.trick("back_flip")

	if rotation_count_y >= 2 * PI:
		rotation_count_y = 0
		game_manager.trick("left_corkscrew")

	if rotation_count_y <= -2 * PI:
		rotation_count_y = 0
		game_manager.trick("right_corkscrew")

	if rotation_count_z >= 2 * PI:
		rotation_count_z = 0
		game_manager.trick("left_spin")

	if rotation_count_z <= -2 * PI:
		rotation_count_z = 0
		game_manager.trick("right_spin")



	if player.is_on_floor():
		
		rotation_count_x = 0
		rotation_count_y = 0
		rotation_count_z = 0
		
		if player.get_global_transform().basis.y.dot(player.get_floor_normal()) > landing_tilt_threshold:
			game_manager.landing(true)
		else:
			game_manager.landing(false)
		
		
		# Uprights the Character
		player.transform.basis.y = Vector3.UP
		player.transform.basis.x = -player.get_global_transform().basis.z.cross(Vector3.UP)
		player.transform.basis = player.get_global_transform().basis.orthonormalized()
		
		_state_machine.transition_to("OnBike")

#turn function
static func get_input_direction(posInput: String, negInput: String) -> float:
	return Input.get_action_strength(posInput) - Input.get_action_strength(negInput)

# State transition functions
func enter(msg: = {}):
	
	respawn_manager.respawn_point_update(player.transform.origin)
	
	match msg:
		{"velocity": var v, "jump_impulse": var ji}:
			_parent.velocity = v + Vector3(0.0, ji, 0.0)
	_parent.enter(msg)

func exit():
	_parent.exit()
