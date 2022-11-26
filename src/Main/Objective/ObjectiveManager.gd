extends Node
class_name ObjectiveManager

var player#: Player
var timer: Timer
var game_manager: GameManager
var UI: Control
var audio_manager: AudioManager
var minimap

var timer_started: = false
var active_objective: Objective

const endScreen = preload("res://src/UI/EndScreen/GameOver.tscn")

var completed_objectives: = 0

var delivery_time: float = 0
var delivering = false
#all children of node must be objectives

#sets variables
func _ready():
	yield(owner, "ready")
	player = get_parent().get_node("Player")
	timer = get_parent().get_node("GameTimer")
	game_manager = get_parent().get_node("GameManager")
	UI = get_parent().get_node("Interface")
	audio_manager = get_parent().get_node("SFXManager")
	minimap = get_parent().get_node("Map")
	self.get_child(0).activate()
	active_objective = self.get_child(0)
	
	
func objective_reached(objective):
	objective.deactivate()
	if !timer_started:
		timer.start()
		timer_started = true
	if objective.get_index() == 0:
		#random child between indexes 1 and n of children
		var new_objective
		new_objective = self.get_child(randi() % (self.get_child_count() - 1) + 1)
		new_objective.activate()
		active_objective = new_objective
		
		game_manager.reset_boba()
		game_manager.has_boba = true
		
		#UI
		UI.get_node("Boba").set_visible(true)
		UI.get_node("Notification").display_notification("Head to the Delivery point", 3)
		minimap.notif(5)
		
		#Satisfaction Timer set to expected time to of objective
		delivering = true
		delivery_time = 0
		
	else:
		# code for adding time to the timer when objective reached
		timer.start(timer.get_time_left() + 10)
		completed_objectives += 1
		game_manager.delivery(delivery_time, active_objective.expected_time_to)
		self.get_child(0).activate()
		active_objective = self.get_child(0)
		
		#sound
		audio_manager.play("res://Assets/Audio/sfx_coin_cluster5.wav")
		
		#Sat timer stop
		delivering = false
		
		game_manager.has_boba = false
		
		# TODO UI add sentiment
		
		#UI
		UI.get_node("Boba").set_visible(false)
		UI.get_node("Notification").display_notification("Head to Bonbas Boba", 3)
		minimap.notif(5)

func _process(delta):
	if delivering: delivery_time += delta

func _on_GameTimer_timeout():
	var enddScreen = endScreen.instance()
	get_parent().add_child(enddScreen)
	enddScreen.delivery.set_text(str(enddScreen.delivery.get_text(), completed_objectives))
	enddScreen.score.set_text(str(enddScreen.score.get_text(), game_manager.points))
	
	
	enddScreen.perfect.set_text(str(enddScreen.perfect.get_text(), game_manager.perfect_deliveries))
	enddScreen.excellent.set_text(str(enddScreen.excellent.get_text(), game_manager.excellent_deliveries))
	enddScreen.great.set_text(str(enddScreen.great.get_text(), game_manager.great_deliveries))
	enddScreen.good.set_text(str(enddScreen.good.get_text(), game_manager.good_deliveries))
	enddScreen.subpar.set_text(str(enddScreen.subpar.get_text(), game_manager.subpar_deliveries))
	
	var deliveries = [game_manager.perfect_deliveries, game_manager.excellent_deliveries, 
		game_manager.great_deliveries, game_manager.good_deliveries, game_manager.subpar_deliveries]
	
	match deliveries.find(deliveries.max()) :
		0:
			enddScreen.letter.texture = load("res://Assets/Textures/UI/End Screen/Ranks/S_Rank.png")
		1:
			enddScreen.letter.texture = load("res://Assets/Textures/UI/End Screen/Ranks/A_Rank.png")
		2:
			enddScreen.letter.texture = load("res://Assets/Textures/UI/End Screen/Ranks/B_Rank.png")
		3:
			enddScreen.letter.texture = load("res://Assets/Textures/UI/End Screen/Ranks/C_Rank.png")
		4:
			enddScreen.letter.texture = load("res://Assets/Textures/UI/End Screen/Ranks/F_Rank.png")
		_:
			enddScreen.letter.texture = load("res://Assets/Textures/UI/End Screen/Ranks/A_Rank.png")
	
	
	
	get_tree().paused = true
