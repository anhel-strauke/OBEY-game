extends 'res://scenes/game/character_drivers/aistates/StageAwareState.gd'

var target

# TODO: Remove "safe zone" :) 
var safe_zone = null

func initialize(newTarget):
	target = newTarget

func update(Variant):
	._update()
	velocity_vector = player.position.direction_to(target.position)
	var distance = player.position.distance_to(target.position)
	if distance < 50:
		emit_signal("finished", "previous")
		emit_signal("finished", "hold_position")
	if safe_zone != null:
		var safe_zone_distance = safe_zone.distance_to(target.position)
		if safe_zone_distance < 250:
			emit_signal("finished", "previous")
	#if event.is_action_pressed("attack"):
	#	if current_state in [$Attack, $Stagger]:
	#		return
	#	_change_state("attack")
	#	return

func get_state_description():
	if target == null:
		return "FollowPlayer is uninitialized!"
	return "Chasing " + target.get_name()
