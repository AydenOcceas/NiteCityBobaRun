extends Spatial
class_name NickyBoy

func set_transparency(transparency: bool):
	get_node("Armature/Skeleton/Character").get_active_material(0).set_shader_param("stippled_transparent", transparency)
	get_node("Bike").get_active_material(0).set_shader_param("stippled_transparent", transparency)
