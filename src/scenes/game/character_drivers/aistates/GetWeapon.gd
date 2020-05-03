extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

var target_position: Vector2

func initialize(newTarget: Vector2):
	target_position = newTarget
	_assign_path(newTarget)

func update(Variant):
	._update()
	velocity_vector = get_path_direction.call_func()
	#emit_signal("finished", "previous")


func get_state_description():
	return "Picking up weapon"
