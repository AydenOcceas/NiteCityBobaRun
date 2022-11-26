extends Node
class_name StateMachine


signal transitioned(state_path)

#used to assign the inital state to a state in the node editor
export var initial_state: = NodePath()

#gets the node from the nodepath
onready var state: State = get_node(initial_state) setget set_state
onready var _state_name := state.name

func _init():
	add_to_group("state_machine")


func _ready():
	yield(owner, "ready")
	state.enter()

#delegates logic to whatever state is currently active
func _unhandled_input(event):
	state.unhandled_input(event)

#delegates logic to whatever state is currently active
func _process(delta):
	state.process(delta)

#delegates logic to whatever state is currently active
func _physics_process(delta):
	state.physics_process(delta)

#logic for transitioning from state to state
func transition_to(target_state_path: String, msg: = {}) -> void:
	#makes sure target state exists
	if not has_node(target_state_path):
		return
	
	#gets target state node from target state node path
	var target_state: = get_node(target_state_path)
	
	#exits old state
	state.exit()
	#sets new state
	self.state = target_state
	#runs code for new state
	state.enter(msg)
	emit_signal("transitioned", target_state_path)


func set_state(value: State):
	state = value
	_state_name = state.name
