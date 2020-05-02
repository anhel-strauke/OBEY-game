extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

const COUNTDOWN_UPDATE_COUNT: int = 240
var countdown = COUNTDOWN_UPDATE_COUNT
var target_position: Vector2

func initialize(newTarget: Vector2):
	goal_avoid_enemies = true
	target_position = newTarget

# TODO: [obstacles] Avoid direct ray traces to players
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

func get_state_description():
	return "Fleeing"
