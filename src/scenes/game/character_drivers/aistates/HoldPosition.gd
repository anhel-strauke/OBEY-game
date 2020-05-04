extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

var target_position: Vector2

const COUNTDOWN_UPDATE_COUNT: int = 100
var countdown = COUNTDOWN_UPDATE_COUNT

func initialize(newTarget: Vector2):
	target_position = newTarget

func update(Variant):
	._update()
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
	return true

func get_state_description():
	return "Holding position"
