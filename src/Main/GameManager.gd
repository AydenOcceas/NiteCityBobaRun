extends Node
class_name GameManager

var player#: Player
var ui: Control
var audio_manager: AudioManager

var points: int = 0
export var subpar_deliveries: int = 0
export var good_deliveries: int = 0
export var great_deliveries: int = 0
export var excellent_deliveries: int = 0
export var perfect_deliveries: int = 0

var boba_shakeness: float = 0
var current_boba_level:int = 0

var point_queue: int
var combo: int

export var subpar_delivery_points: int
export var good_delivery_points: int
export var great_delivery_points: int
export var excellent_delivery_points: int
export var perfect_delivery_points: int

export var combo_modifier: int
export var flip_points: int
export var corkscrew_points: int
export var spin_points: int

var has_boba = false

export var boba_shake: float
export var boba_falloff: float
export var boba_superCharged_falloff: float
	
export var boba_rocked_threshold: float
export var boba_shaken_threshold: float
export var boba_vibrated_threshold: float
export var boba_superCharged_threshold: float


func _ready():
	yield(owner, "ready")
	player = get_parent().get_node("Player")
	ui = get_parent().get_node("Interface")
	audio_manager = get_parent().get_node("SFXManager")
	
	

func _process(delta):
	if has_boba: update_boba(delta)

func trick(name: String):
	match name:
		"front_flip", "back_flip":
			point_queue += flip_points + (combo_modifier * combo)
			combo += 1
			ui.get_node("Trick").trick_display(name.replace("_", " "))
		"right_corkscrew", "left_corkscrew":
			point_queue += corkscrew_points + (combo_modifier * combo)
			combo += 1
			ui.get_node("Trick").trick_display(name.replace("_", " "))
		"right_spin", "left_spin":
			point_queue += spin_points + (combo_modifier * combo)
			combo += 1
			ui.get_node("Trick").trick_display(name.replace("_", " "))
	
	ui.get_node("PointAdd").push_queue(point_queue)
	
	if has_boba: 
		shake_boba()
		var BobaAnimPlayer: AnimationPlayer = ui.get_node("Boba/AnimationPlayer")
		BobaAnimPlayer.play("Shake")

func landing(good: bool):
	if good:
		points += point_queue
		ui.get_node("Trick").trick_display(" ")
		if point_queue: audio_manager.play("res://Assets/Audio/sfx_sounds_powerup11.wav")
		point_queue = 0
		combo = 0
	else:
		ui.get_node("Trick").trick_display(" ")
		point_queue = 0
		combo = 0
		audio_manager.play("res://Assets/Audio/sfx_sounds_error3.wav")
	ui.get_node("PointAdd").end_queue(good)

func delivery(time_of_delivery: float, expected_delievery_time: float):
	# late
	if time_of_delivery > expected_delievery_time:
		points += subpar_delivery_points
		subpar_deliveries += 1
		ui.get_node("SentimentBackground").display_notification(0, 5)
	# undershaken
	elif boba_shakeness < boba_rocked_threshold:
		points += subpar_delivery_points
		subpar_deliveries += 1
		ui.get_node("SentimentBackground").display_notification(1, 5)
	# rocked
	elif boba_shakeness < boba_shaken_threshold:
		points += good_delivery_points
		good_deliveries += 1
		ui.get_node("SentimentBackground").display_notification(2, 5)
	# shaken
	elif boba_shakeness < boba_vibrated_threshold:
		points += great_delivery_points
		great_deliveries += 1
		ui.get_node("SentimentBackground").display_notification(3, 5)
	# vibrated
	elif boba_shakeness < boba_vibrated_threshold:
		points += excellent_delivery_points
		excellent_deliveries += 1
		ui.get_node("SentimentBackground").display_notification(4, 5)
	else:
		points += perfect_delivery_points
		perfect_deliveries += 1
		ui.get_node("SentimentBackground").display_notification(5, 5)


#BOBA SHAKE
func reset_boba():
	boba_shakeness = 0

func shake_boba():
	boba_shakeness += boba_shake
	# todo: points on surpassing threshold but only once per reset

func update_boba(delta):
	if boba_shakeness - boba_falloff < boba_rocked_threshold:
		pass
	elif boba_shakeness > boba_superCharged_threshold:
		boba_shakeness -= boba_superCharged_falloff * delta
	else:
		boba_shakeness -= boba_falloff * delta
	
	if boba_shakeness > boba_superCharged_threshold:
		if current_boba_level != 4:
			current_boba_level = 4
			update_boba_ui(4)
	elif boba_shakeness > boba_vibrated_threshold:
		if current_boba_level != 3:
			current_boba_level = 3
			update_boba_ui(3)
	elif boba_shakeness > boba_shaken_threshold:
		if current_boba_level != 2:
			current_boba_level = 2
			update_boba_ui(2)
	elif boba_shakeness > boba_rocked_threshold:
		if current_boba_level != 1:
			current_boba_level = 1
			update_boba_ui(1)
	else:
		if current_boba_level != 0:
			current_boba_level = 0
			update_boba_ui(0)

func update_boba_ui(level: int):
	var boba_image:Sprite = ui.get_node("Boba")
	match level:
		0:
			boba_image.texture =  load("res://Assets/Textures/UI/Boba/Boba.png")
		1:
			boba_image.texture = load("res://Assets/Textures/UI/Boba/Boba_Rocked.png")
		2:
			boba_image.texture = load("res://Assets/Textures/UI/Boba/Boba_Shaken.png")
		3:
			boba_image.texture = load("res://Assets/Textures/UI/Boba/Boba_SuperCharged.png")
		4:
			boba_image.texture = load("res://Assets/Textures/UI/Boba/Boba_Vibrated.png")
		_:
			boba_image.texture = load("res://Assets/Textures/UI/Boba/Boba.png")
