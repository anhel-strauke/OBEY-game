extends "res://scripts/state_machine/state.gd"


var player
var target_position

const COUNTDOWN_UPDATE_COUNT: int = 60
var countdown = COUNTDOWN_UPDATE_COUNT

func initialize(newPlayer, newTarget):
	player = newPlayer
	target_position = newTarget

# TODO: [obstacles] Avoid direct ray traces to players
func update(Variant):
	var distance = player.position.distance_to(target_position)
	if distance < 200:
		velocity_vector = Vector2()
		countdown -= 1
		if countdown < 1:
			countdown = COUNTDOWN_UPDATE_COUNT
			emit_signal("finished", "previous")
	else:
		velocity_vector = player.position.direction_to(target_position)
		countdown = COUNTDOWN_UPDATE_COUNT

func get_state_description():
	return "Fleeing"
