extends Spatial

var player: Player

export var smooth_follow_speed: float
export var velocity_to_rotate_threshold: float

func _ready():
	yield(owner, "ready")
	player = get_player()


func _process(delta):
	
	var player_velocity = player.state_machine.state.velocity
	var rotate_amount: float
	rotate_amount = atan2(
		player_velocity.normalized().x,
		player_velocity.normalized().z
	)
	
	if Vector2(player_velocity.x, player_velocity.z).length() > velocity_to_rotate_threshold:
		self.rotation.y = rotate_amount

	#Camera Smooth Follow with smooth follow of rotation based on velocity
	self.transform.origin = lerp(
		self.transform.origin, 
		vec3_stepify(player.transform.origin, 0.01),
		smooth_follow_speed * delta)

	
func vec3_stepify(vec3: Vector3, step: float) -> Vector3:
	return Vector3(
		stepify(vec3.x, step),
		stepify(vec3.y, step),
		stepify(vec3.z, step)
	)
	
func get_player():
	return get_parent().get_node("Player")
