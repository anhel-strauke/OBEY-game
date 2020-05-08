extends Node

enum Buttons {
	Up,
	Down,
	Left,
	Right,
	Fire,
	AddFire,
	Evade,
	Pause
}

const BUTTON_ACTIONS = {
	Constants.Actions.Fire: Buttons.Fire,
	Constants.Actions.AddFire: Buttons.AddFire,
	Constants.Actions.Evade: Buttons.Evade,
	Constants.Actions.Pause: Buttons.Pause
}

const MAPPINGS = [
	{
		Buttons.Up: KEY_W,
		Buttons.Down: KEY_S,
		Buttons.Left: KEY_A,
		Buttons.Right: KEY_D,
		Buttons.Fire: KEY_C,
		Buttons.AddFire: KEY_V,
		Buttons.Evade: KEY_B,
		Buttons.Pause: KEY_ESCAPE
	},
	{
		Buttons.Up: KEY_UP,
		Buttons.Down: KEY_DOWN,
		Buttons.Left: KEY_LEFT,
		Buttons.Right: KEY_RIGHT,
		Buttons.Fire: KEY_O,
		Buttons.AddFire: KEY_P,
		Buttons.Evade: KEY_I,
		Buttons.Pause: KEY_ESCAPE
	}
]


var mapping: int = 0 setget set_mapping

var _direction: Vector2 = Vector2.ZERO
var _actions_just_pressed = {
	Constants.Actions.Fire: false,
	Constants.Actions.AddFire: false,
	Constants.Actions.Evade: false,
	Constants.Actions.Pause: false
}
var _actions_was_pressed = {
	Constants.Actions.Fire: false,
	Constants.Actions.AddFire: false,
	Constants.Actions.Evade: false,
	Constants.Actions.Pause: false
}

func direction() -> Vector2:
	return _direction


func _key_for_action(action: int) -> int:
	var map = MAPPINGS[mapping]
	var button = BUTTON_ACTIONS[action]
	return map[button]


func is_pressed(action: int) -> bool:
	var key = _key_for_action(action)
	return Input.is_key_pressed(key)


func is_just_pressed(action: int) -> bool:
	return _actions_just_pressed[action]


func _process(_delta: float) -> void:
	for action in _actions_just_pressed.keys():
		_actions_just_pressed[action] = is_pressed(action) and not _actions_was_pressed[action]
		_actions_was_pressed[action] = is_pressed(action)
	var map = MAPPINGS[mapping]
#	var x_axis = 0.0
#	var y_axis = 0.0
#	if Input.is_key_pressed(map[Buttons.Up]):
#		y_axis = -1.0
#	elif Input.is_key_pressed(map[Buttons.Down]):
#		y_axis = 1.0
#	if Input.is_key_pressed(map[Buttons.Left]):
#		x_axis = -1.0
#	elif Input.is_key_pressed(map[Buttons.Right]):
#		x_axis = 1.0
#	_direction = Vector2(x_axis, y_axis).normalized()

	var x_axis = 0.0
	var y_axis = 0.0
	if Input.is_key_pressed(map[Buttons.Up]):
		y_axis = -1.0
	elif Input.is_key_pressed(map[Buttons.Down]):
		y_axis = 1.0
	if Input.is_key_pressed(map[Buttons.Left]):
		x_axis = -1.0
	elif Input.is_key_pressed(map[Buttons.Right]):
		x_axis = 1.0

	var angle = atan2(_real_direction.y, _real_direction.x)
	var angle_change = atan2(y_axis, x_axis)
#	angle += angle_change * _delta * 10.0
	angle = lerp_angle(angle, angle_change, _delta*10.0)

	_real_direction = Vector2(cos(angle), sin(angle))
	_direction = _real_direction * Vector2(x_axis, y_axis).length()

var _real_direction = Vector2(0.0, 0.0)


func set_mapping(m: int) -> void:
	if m >= 0 and m < len(MAPPINGS):
		mapping = m
	else:
		mapping = 0
