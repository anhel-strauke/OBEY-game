extends Node

const MAPPING = {
	Constants.Actions.Fire: [GamepadManager.GamepadButton.A],
	Constants.Actions.AddFire: [GamepadManager.GamepadButton.B],
	Constants.Actions.Evade: [GamepadManager.GamepadButton.X, GamepadManager.GamepadButton.R1],
	Constants.Actions.Pause: [GamepadManager.GamepadButton.Start]
}

var _direction: Vector2 = Vector2.ZERO
var device_id: int = -1 setget set_device_id
var _actions_pressed = {
	Constants.Actions.Fire: -1,
	Constants.Actions.AddFire: -1,
	Constants.Actions.Evade: -1,
	Constants.Actions.Pause: -1
}
var _actions_just_pressed = {}


func _init():
	for action in _actions_pressed.keys():
		_actions_just_pressed[action] = false


func set_device_id(id: int) -> void:
	if GamepadManager.device_ids().find(id) >= 0:
		device_id = id
		GamepadManager.activate(id)
	else:
		device_id = -1


func direction() -> Vector2:
	return _direction


func is_pressed(action: int) -> bool:
	if device_id >= 0:
		var buttons = MAPPING[action]
		for button in buttons:
			if GamepadManager.get_button(device_id, button):
				return true
	return false


func is_just_pressed(action: int) -> bool:
	return _actions_just_pressed[action]


func _process(_delta: float) -> void:
	if device_id < 0:
		return
	for action in _actions_pressed.keys():
		var buttons = MAPPING[action]
		for button in buttons:
			if GamepadManager.get_button(device_id, button):
				if _actions_pressed[action] == -1:
					_actions_pressed[action] = button
			else:
				if _actions_pressed[action] == button:
					_actions_pressed[action] = -1
		_actions_just_pressed[action] = _actions_pressed[action] != -1 and not _actions_just_pressed[action]
	var x_axis = GamepadManager.get_axis(device_id, GamepadManager.GamepadAxis.LX)
	var y_axis = GamepadManager.get_axis(device_id, GamepadManager.GamepadAxis.LY)
	_direction = Vector2(x_axis, y_axis)
	var dir_len = _direction.length()
	if dir_len < 0.1:
		_direction = Vector2.ZERO
	elif dir_len > 1.0:
		_direction = _direction.normalized()
