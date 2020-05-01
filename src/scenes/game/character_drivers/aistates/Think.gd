extends "res://scripts/state_machine/state.gd"

var enemies = []
var target # TODO: Stack parameters

var enemy_iterator = 0

func update(_delta):
	target = enemies[enemy_iterator]
	print(enemy_iterator)
	enemy_iterator += 1
	if enemy_iterator == enemies.size():
		enemy_iterator = 0	
	emit_signal("finished", "follow_player")

func get_state_description():
	return "Think"
