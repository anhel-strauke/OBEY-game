extends Node

const AXIS_TRIGGER_TRESHOLD = 0.8

const KeyboardInputSource = preload("res://scripts/KeyboardInputSource.gd")
const GamepadInputSource = preload("res://scripts/GamepadInputSource.gd")

signal player_controls_reset_to_keyboard(player_index)

signal player_controls_changed_to_keyboard(player_index)
signal player_controls_changed_to_gamepad(player_index)


class Player:
	var index = 0
	var input_source = null
	
	func is_keyboard_input_source():
		return input_source != null and input_source is KeyboardInputSource
	
	func is_gamepad_input_source():
		return input_source != null and input_source is GamepadInputSource
	
	func _init(idx: int):
		index = idx
	
	func direction() -> Vector2:
		if input_source:
			return input_source.direction()
		return Vector2.ZERO
	
	func is_pressed(action: int) -> bool:
		if input_source:
			return input_source.is_pressed(action)
		return false
	
	func is_just_pressed(action: int) -> bool:
		if input_source:
			return input_source.is_just_pressed(action)
		return false


var players = [
	Player.new(0),
	Player.new(1)
]

var _common_actions_just_pressed = {
	Constants.CommonActions.Up: false,
	Constants.CommonActions.Down: false,
	Constants.CommonActions.Left: false,
	Constants.CommonActions.Right: false,
	Constants.CommonActions.Enter: false,
	Constants.CommonActions.Esc: false
}

var _common_actions_pressed = []

const COMMON_KEYBOARD_MAPPING = {
	Constants.CommonActions.Up: [KEY_UP, KEY_W],
	Constants.CommonActions.Down: [KEY_DOWN, KEY_S],
	Constants.CommonActions.Left: [KEY_LEFT, KEY_A],
	Constants.CommonActions.Right: [KEY_RIGHT, KEY_D],
	Constants.CommonActions.Enter: [KEY_ENTER],
	Constants.CommonActions.Esc: [KEY_ESCAPE, KEY_BACKSPACE, KEY_BACK]
}

const COMMON_GAMEPAD_BUTTON_MAPPING = {
	Constants.CommonActions.Enter: GamepadManager.GamepadButton.A,
	Constants.CommonActions.Esc: GamepadManager.GamepadButton.B
}

var common_input_mode := false setget set_common_input_mode


func player(index) -> Player:
	return players[index]


func set_keyboard_input_source(player_index: int) -> void:
	var player = players[player_index]
	if player.input_source and player.input_source is KeyboardInputSource:
		return
	if player.input_source:
		remove_child(player.input_source)
		player.input_source.queue_free()
	player.input_source = KeyboardInputSource.new()
	add_child(player.input_source)
	player.input_source.mapping = player_index
	emit_signal("player_controls_changed_to_keyboard", player_index)


func set_gamepad_input_source(player_index: int, device_id: int) -> void:
	var player = players[player_index]
	if player.input_source:
		remove_child(player.input_source)
		player.input_source.queue_free()
	player.input_source = GamepadInputSource.new()
	add_child(player.input_source)
	player.input_source.device_id = device_id
	emit_signal("player_controls_changed_to_gamepad", player_index)


func remove_input_source(player_index: int) -> void:
	var player = players[player_index]
	if player.input_source:
		remove_child(player.input_source)
		player.input_source.queue_free()


func _on_gamepad_removed(device_id: int) -> void:
	for player in players:
		if player.input_source is GamepadInputSource:
			var gamepad_source = player.input_source as GamepadInputSource
			if gamepad_source.device_id == device_id:
				set_keyboard_input_source(player.index)
				emit_signal("player_controls_reset_to_keyboard", player.index)


func _on_gamepad_connected(device_id: int) -> void:
	if common_input_mode:
		activate_common_input_for_gamepads()


func _ready() -> void:
	GamepadManager.connect("gamepad_connected", self, "_on_gamepad_connected")
	GamepadManager.connect("gamepad_disconnected", self, "_on_gamepad_removed")


func activate_common_input_for_gamepads():
	GamepadManager.activate_all_configured()


func deactivate_common_input_for_gamepads():
	var gamepads_in_use = []
	for player in players:
		if player.input_source and player.input_source is GamepadInputSource:
			gamepads_in_use.append(player.input_source.device_id)
	GamepadManager.deactivate_all_except(gamepads_in_use)


func _process(_delta: float) -> void:
	if not common_input_mode:
		return
	var pressed_actions = []
	for action in _common_actions_just_pressed.keys():
		var keys = COMMON_KEYBOARD_MAPPING[action]
		for key in keys:
			var is_pressed = Input.is_key_pressed(key)
			if is_pressed and pressed_actions.find(action) < 0:
				pressed_actions.append(action)
	var active_gamepads = GamepadManager.active_device_ids()
	if len(active_gamepads) > 0:
		for action in COMMON_GAMEPAD_BUTTON_MAPPING.keys():
			for gamepad_id in active_gamepads:
				if GamepadManager.is_configured(gamepad_id):
					var button = COMMON_GAMEPAD_BUTTON_MAPPING[action]
					var is_pressed = GamepadManager.get_button(gamepad_id, button)
					if is_pressed and pressed_actions.find(action) < 0:
						pressed_actions.append(action)
		for gamepad_id in active_gamepads:
			if GamepadManager.is_configured(gamepad_id):
				var y_axis = GamepadManager.get_axis(gamepad_id, GamepadManager.GamepadAxis.LY)
				var x_axis = GamepadManager.get_axis(gamepad_id, GamepadManager.GamepadAxis.LX)
				var is_pressed = {
					Constants.CommonActions.Up: y_axis < -AXIS_TRIGGER_TRESHOLD,
					Constants.CommonActions.Down: y_axis > AXIS_TRIGGER_TRESHOLD,
					Constants.CommonActions.Left: x_axis < -AXIS_TRIGGER_TRESHOLD,
					Constants.CommonActions.Right: x_axis > AXIS_TRIGGER_TRESHOLD
				}
				for act in is_pressed.keys():
					if is_pressed[act] and pressed_actions.find(act) < 0:
						pressed_actions.append(act)
	for act in _common_actions_just_pressed.keys():
		_common_actions_just_pressed[act] = pressed_actions.find(act) >= 0 and  _common_actions_pressed.find(act) == -1
	_common_actions_pressed = pressed_actions


func set_common_input_mode(mode: bool):
	if common_input_mode != mode:
		common_input_mode = mode
		if mode:
			activate_common_input_for_gamepads()
		else:
			deactivate_common_input_for_gamepads()


func is_common_action_just_pressed(action: int) -> bool:
	return _common_actions_just_pressed[action]
