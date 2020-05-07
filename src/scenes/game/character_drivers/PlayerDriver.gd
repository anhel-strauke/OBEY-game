extends Node
class_name PlayerDriver

export(int) var player_index: int = -1

enum {
	SEQ_NONE,
	SEQ_UP,
	SEQ_DOWN,
	SEQ_LEFT,
	SEQ_RIGHT,
	SEQ_B,
	SEQ_A
}

var _sequence = []
const _good_sequence = [
	SEQ_UP,
	SEQ_UP,
	SEQ_DOWN,
	SEQ_DOWN,
	SEQ_LEFT,
	SEQ_RIGHT,
	SEQ_LEFT,
	SEQ_RIGHT,
	SEQ_B,
	SEQ_A
]

var _was_pressed_actions = []
var _last_direction = []

signal sequence_completed()


func _seq_value_from_direction(dir: Vector2) -> Array:
	var result = []
	if dir.x > 0.7:
		result.append(SEQ_RIGHT)
	elif dir.x < -0.7:
		result.append(SEQ_LEFT)
	if dir.y > 0.7:
		result.append(SEQ_DOWN)
	elif dir.y < -0.7:
		result.append(SEQ_UP)
	return result


func _add_seq(seq_item: int) -> void:
	_sequence.append(seq_item)
	match seq_item:
		SEQ_UP:
			print("Up")
		SEQ_DOWN:
			print("Down")
		SEQ_LEFT:
			print("Left")
		SEQ_RIGHT:
			print("Right")
		SEQ_A:
			print("A")
		SEQ_B:
			print("B")
	var diff = len(_sequence) - len(_good_sequence)
	if diff > 0:
		for i in diff:
			_sequence.remove(0)
	if len(_sequence) == len(_good_sequence):
		var ok = true
		for i in len(_sequence):
			if _sequence[i] != _good_sequence[i]:
				ok = false
				break
		if ok:
			emit_signal("sequence_completed")
			_sequence = []


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


func _process(delta: float) -> void:
	var pressed_dir = _seq_value_from_direction(GameInput.player(player_index).direction())
	var pressed_actions = []
	if GameInput.player(player_index).is_pressed(Constants.Actions.Fire):
		pressed_actions.append(SEQ_A)
	elif GameInput.player(player_index).is_pressed(Constants.Actions.AddFire):
		pressed_actions.append(SEQ_B)
	if _last_direction == [] and len(pressed_dir) > 0:
		for d in pressed_dir:
			_add_seq(d)
	for act in pressed_actions:
		if not _was_pressed_actions.has(act):
			_add_seq(act)
	_last_direction = pressed_dir
	_was_pressed_actions = pressed_actions
