extends Node2D

func _ready():
	var controller = get_tree().get_nodes_in_group("postproc_controller")[0]
	controller.create_ripple(self)
	controller.rotation = PI/2.0
