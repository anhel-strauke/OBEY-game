extends Node
class_name PlayerDriver

export(int) var player_index: int = -1

func get_velocity_vector() -> Vector2:
	if player_index >= 0:
		return GameInput.player(player_index).direction()
	return Vector2.ZERO

func is_fire_pressed() -> bool:
	if player_index >= 0:
		return GameInput.player(player_index).is_pressed(Constants.Actions.Fire)
	return false


func is_ability_pressed() -> bool:
	if player_index >= 0:
		return GameInput.player(player_index).is_pressed(Constants.Actions.AddFire)
	return false

func _process(delta):
	if get_parent().name == 'Tower5G':
		get_parent()._suicide()
	pass
