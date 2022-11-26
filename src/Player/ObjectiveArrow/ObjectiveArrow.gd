extends Spatial
class_name ObjectiveArrow

var objective: Spatial

func _ready():
	self.visible = false

func _process(delta):
	if objective != null:
		self.look_at(
			Vector3(
				objective.transform.origin.x,
				0,
				objective.transform.origin.z), 
			Vector3.UP)
		self.visible = true
	else:
		self.visible = false
