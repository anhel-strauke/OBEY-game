extends Node2D

export(NodePath) var light_system_path

export var intensity = 0

var light_id = 0

var light_system
# Called when the node enters the scene tree for the first time.
func _ready():
	if light_system_path:
		light_system = get_node(light_system_path)
	else:
		light_system = get_light_system()
	light_system.add_light(self)
	print("rlight ready: ", light_id)
	_process(0)

func get_light_system():
	return get_tree().get_root().get_node("World").get_node("LightSystem")

func _process(delta):
	var coeff = intensity/500.0
	$Sprite.scale.x = coeff
	$Sprite.scale.y = coeff

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		light_system.light_removed(self)
	#._notification(what)
