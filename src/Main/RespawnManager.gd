extends Node
class_name RespawnManager

var current_respawn_point: Spatial

func _ready():
	current_respawn_point = get_child(30)

func respawn_point_update(position: Vector3):
	var closest_point = get_child(0)
	var distance = get_child(0).get_translation().distance_to(position)

	for num in get_child_count():
		var current_distance = get_child(num).get_translation().distance_to(position)
		print(current_distance)

		if current_distance < distance:
			closest_point = get_child(num)
			distance = current_distance
	
	current_respawn_point = closest_point

func respawn(player):
	player.state_machine.state.velocity = Vector3.ZERO
	player.set_translation(current_respawn_point.get_translation())
	player.state_machine.transition_to("OnBike/Air", {})


func _on_Area_body_entered(body):
	respawn(body)
