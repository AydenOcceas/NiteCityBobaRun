extends State
class_name PlayerState

var player: Player
var skin: NickyBoy

func _ready():
	yield(owner, "ready")
	player = owner
	skin = player.skin
