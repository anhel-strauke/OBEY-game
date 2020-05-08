extends Node


var game_is_on: bool = false
var game_just_started: bool = true
var last_selected_chars = []


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func find_bullet_parent() -> Node2D:
	var nodes = get_tree().get_nodes_in_group("BulletParent")
	if nodes.size() > 0:
		return nodes[0]
	return null
