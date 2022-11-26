extends  PlayerState

var respawn_manager: RespawnManager

var velocity: = Vector3.ZERO
var knock_rot: = Vector3.ZERO
export var knock_time: float

func _ready():
	yield(owner, "ready")
	respawn_manager = get_tree().root.get_node("Game/RespawnManager")

func physics_process(delta):
	_parent.physics_process(delta)
	velocity = _parent.velocity
	
	player.rotate_x(knock_rot.x)
	player.rotate_y(knock_rot.y)
	player.rotate_z(knock_rot.z)
	
	
	if player.is_on_floor():
	# Uprights the Character
		player.transform.basis.y = Vector3.UP
		player.transform.basis.x = -player.get_global_transform().basis.z.cross(Vector3.UP)
		player.transform.basis = player.get_global_transform().basis.orthonormalized()
		
		
		_state_machine.transition_to("OnBike")

# State transition functions

# transfers values between states using msg
func enter(msg: = {}):
	player.set_collision_layer_bit(1, false)
	player.set_collision_layer_bit(3, true)
	
	player.get_node("NickyBoy").set_transparency(true)
	
	knock_rot = Vector3(rand_range(0.1, 0.2), rand_range(0.1, 0.2), rand_range(0.1, 0.2))
	
	_parent.velocity += Vector3(0.0, 15, 0.0)
	
	respawn_manager.respawn_point_update(player.transform.origin)
	
	return

# reset values and disconnect signals
func exit():
	player.set_collision_layer_bit(1, true)
	player.set_collision_layer_bit(3, false)
	
	player.get_node("NickyBoy").set_transparency(false)
	return
