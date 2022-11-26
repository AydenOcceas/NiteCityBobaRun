extends Spatial
class_name Objective

#Objective rotation rate
export var rotation_rate: = 0.01
export var expected_time_to = 45

var objective_manager
var area: Area
var active: = false

#turns off objective and assigns area and objective manager variables
func _ready():
	self.set_visible(false)
	yield(owner, "ready")
	objective_manager = get_parent()
	area = get_child(0)

func _process(delta):
	if active:
		pass
		#self.rotate_y(rotation_rate)

#set active to true and turns on visability and area monitoring
# also turning the objective arro
func activate():
	active = true
	self.set_visible(true)
	area.monitoring = true

#returns objective to deactivated state
func deactivate():
	active = false
	self.set_visible(false)
	area.set_deferred("monitoring", false)

#if the player enters the area and the objective is the active objective
#tell the objective manager the objective has been reached
func _on_Area_body_entered(body):
	if body == objective_manager.player && self == objective_manager.active_objective:
		objective_manager.objective_reached(self)
