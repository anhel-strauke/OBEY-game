extends Node2D

const Ripple = preload("res://scenes/game/effects/Ripple.tscn")

func _ready():
	pass # Replace with function body.

func _process(delta):
	for item_id in items:
		var item = items[item_id]['item']
		var controller = items[item_id]['controller']
		if is_instance_valid(controller):
			item.global_position = controller.global_position
			item.rotation = controller.rotation
		else:
			item.queue_free()
			items.erase(item_id)

var max_id = 0
var items = {}

func create_ripple(controller):
	max_id += 1
	var item = Ripple.instance()
	$BackBufferCopy.add_child(item)
	item.global_position = controller.global_position
	item.rotation = controller.rotation
	items[max_id] = {'item': item, 'controller': controller}
