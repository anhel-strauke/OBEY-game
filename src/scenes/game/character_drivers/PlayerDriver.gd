extends Node
class_name PlayerDriver

export(int) var player_index: int = -1


func get_velocity_vector() -> Vector2:
	if player_index >= 0:
		return GameInput.player(player_index).direction()
	return Vector2.ZERO