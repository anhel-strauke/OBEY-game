extends Node2D

export(NodePath) var light_system_path

var light_id = 0

var light_system
# Called when the node enters the scene tree for the first time.
func _ready():
	if light_system_path:
		light_system = get_node(light_system_path)
	else:
		light_system = get_light_system()
	light_system.add_light(self)
	
func get_light_system():
	return get_tree().get_root().get_node("World").get_node("LightSystem")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
