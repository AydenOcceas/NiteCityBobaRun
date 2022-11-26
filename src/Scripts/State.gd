extends Node
class_name State

# figures out what state machine governs the state
onready var _state_machine: = _get_state_machine(self)

# used in the node higherarchy for logic
var _parent: State = null

# gets the parent in the higherarchy
func _ready():
	# waits for the tree to be loaded before trying to get parent
	yield(owner, "ready")
	
	var parent = get_parent() 
	if not parent.is_in_group("state_machine"):
		_parent = parent


# boilerplate function to be replaced with logic in unique states
func unhandled_input(event):
	return

# boilerplate function to be replaced with logic in unique states
func process(delta):
	return

# boilerplate function to be replaced with logic in unique states
func physics_process(delta):
	return


# State transition functions

# transfers values between states using msg
func enter(msg: = {}):
	return

# reset values and disconnect signals
func exit():
	return

# recursive function, goes up the higherarchy looking for a node in group "state_machine"
func _get_state_machine(node: Node) -> Node:
	if node != null and not node.is_in_group("state_machine"):
		return _get_state_machine(node.get_parent())
	return node
