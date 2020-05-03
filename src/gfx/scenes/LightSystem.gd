extends Node2D

const LightScene = preload("res://gfx/scenes/RenderableLight.tscn")

var lights = {}
# Called when the node enters the scene tree for the first time.
var light_id = 0


#func create_light(coords: Vector2, intensity: float):
#	var light = LightScene.instance()
#	light.position = coords
#	light_id += 1
#	light.light_id = light_id
#	lights[light_id] = light
#	add_child(light)
	
func add_light(light):
	light_id += 1
	light.light_id = light_id
	lights[light_id] = light
	
func light_removed(light):
	lights.erase(light.light_id)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
