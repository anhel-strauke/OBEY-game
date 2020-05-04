extends 'res://scenes/game/character_drivers/aistates/StageAwareState.gd'

const COUNTDOWN_UPDATE_COUNT: int = 30
var countdown = COUNTDOWN_UPDATE_COUNT
var target

func initialize(newTarget):
	target = newTarget
	_assign_path(target.position)

func update(Variant):
	._update()
	
	velocity_vector = get_path_direction.call_func()
	
	countdown -= 1
	if countdown < 1:
		countdown = COUNTDOWN_UPDATE_COUNT
		_assign_path(target.position)
	return true

func get_state_description():
	if target == null:
		return "FollowPlayer is uninitialized!"
	return "Chasing " + target.get_name()
