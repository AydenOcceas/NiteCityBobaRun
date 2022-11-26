extends KinematicBody

export var JumpImpulse : float
export var ColorPick : int

onready var colors = [preload("res://Assets/Textures/Car_Textures/Car_Texture.png"), 
	preload("res://Assets/Textures/Car_Textures/Car_Mint_Texture.png"), 
	preload("res://Assets/Textures/Car_Textures/Car_Navy_Texture.png"), 
	preload("res://Assets/Textures/Car_Textures/Car_purple_Texture.png")]

func _ready():
	get_node("Car_Model/Cube").get_active_material(0).set_shader_param("albedoTex", colors[ColorPick])

func _on_Area_body_entered(body):
	if body == get_tree().root.get_node("Game/Player") && body.state_machine.state != body.state_machine.get_node("OnBike/Knocked"):
		get_node("AnimationPlayer").play("Bounce")
		var velocity: Vector3 = body.state_machine.state.velocity
		body.state_machine.transition_to("OnBike/Air", { velocity = velocity, jump_impulse = JumpImpulse})


func _on_Knock_Area_body_entered(body):
	if body == get_tree().root.get_node("Game/Player"):
		body.state_machine.transition_to("OnBike/Knocked", {})
