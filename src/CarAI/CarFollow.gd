extends PathFollow

export var speed: float

func _process(delta):
	set_offset(get_offset() + speed * delta)
	
	var GuidePathFollow = PathFollow.new()
	
	get_parent().add_child(GuidePathFollow)
	GuidePathFollow.set_offset(get_offset() + .05)
	look_at(GuidePathFollow.transform.origin, Vector3.UP)
	GuidePathFollow.queue_free()
	
	
