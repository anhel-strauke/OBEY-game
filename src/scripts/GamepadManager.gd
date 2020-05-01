extends Node

const GAMEPAD_MAPS_FILE = "user://gamepads.json"

enum GamepadButton {
	A, # Cross
	B, # Circle
	X, # Square
	Y, # Triangle
	Start, # Options
	L1, # LB
	R1, # RB
	L2, # LT
	R2, # RB
	LAST
}

enum GamepadAxis {
	LX,
	LY,
	LAST
}

enum GamepadAxisButton {
	LXPlus,
	LXMinus,
	LYPlus,
	LYMinus,
	LAST
}

const GamepadAxisButtonValues = {
	GamepadAxisButton.LXPlus:  [GamepadAxis.LX, 1.0],
	GamepadAxisButton.LXMinus: [GamepadAxis.LX, -1.0],
	GamepadAxisButton.LYPlus:  [GamepadAxis.LY, 1.0],
	GamepadAxisButton.LYMinus: [GamepadAxis.LY, -1.0]
}


class GamepadInputMap:
	var buttons := {} # JOY_BUTTON_X -> GamepadButton.X
	var axis_buttons := {} # JOY_AXIS_X -> GampadAxis.X
	var axis := {} # JOY_BUTTON_X -> GamepadAxisButton.X
	
	func clear():
		buttons = {}
		axis_buttons = {}
		axis = {}
	
	func set_button(input_button_id, gamepad_button):
		buttons[input_button_id] = gamepad_button
	
	func set_axis(input_axis_id, gamepad_axis):
		axis[input_axis_id] = gamepad_axis
	
	func set_axis_button(input_button_id, gamepad_axis_button):
		axis_buttons[input_button_id] = gamepad_axis_button
	
	func get_input_button_id(gamepad_button):
		for button_id in buttons.keys():
			if buttons[button_id] == gamepad_button:
				return button_id
		return -1
	
	func get_input_axis_id(gamepad_axis_id):
		for axis_id in axis.keys():
			if axis[axis_id] == gamepad_axis_id:
				return axis_id
		return -1
	
	func get_axis_button_id(gamepad_axis_button):
		for button_id in axis_buttons.keys():
			if axis_buttons[button_id] == gamepad_axis_button:
				return button_id
		return -1
	
	func save_to_dict():
		var save_buttons = {}
		for button_id in buttons.keys():
			save_buttons[str(button_id)] = buttons[button_id]
		var save_axis = {}
		for axis_id in axis.keys():
			save_axis[str(axis_id)] = axis[axis_id]
		var save_axis_buttons = {}
		for button_id in axis_buttons.keys():
			save_axis_buttons[str(button_id)] = axis_buttons[button_id]
		var save_data = {
			"buttons": save_buttons,
			"axis": save_axis,
			"axis_buttons": save_axis_buttons
		}
		return save_data
	
	func load_from_dict(d):
		var str_buttons = d.get("buttons", {})
		var str_axis = d.get("axis", {})
		var str_axis_buttons = d.get("axis_buttons", {})
		clear()
		for str_id in str_buttons.keys():
			buttons[int(str_id)] = str_buttons[str_id]
		for str_id in str_axis.keys():
			axis[int(str_id)] = str_axis[str_id]
		for str_id in str_axis_buttons.keys():
			axis_buttons[int(str_id)] = str_axis_buttons[str_id]


class InputMapManager:
	var DEFAULT_MAP = { # XBox map
		"buttons": {
			JOY_XBOX_A: GamepadButton.A,
			JOY_XBOX_B: GamepadButton.B,
			JOY_XBOX_X: GamepadButton.X,
			JOY_XBOX_Y: GamepadButton.Y,
			JOY_START: GamepadButton.Start,
			JOY_L: GamepadButton.L1,
			JOY_L2: GamepadButton.L2,
			JOY_R: GamepadButton.R1,
			JOY_R2: GamepadButton.R2
		},
		"axis": {
			JOY_ANALOG_LX: GamepadAxis.LX,
			JOY_ANALOG_LY: GamepadAxis.LY
		},
		"axis_buttons": {
			JOY_DPAD_UP: GamepadAxisButton.LYMinus,
			JOY_DPAD_DOWN: GamepadAxisButton.LYPlus,
			JOY_DPAD_LEFT: GamepadAxisButton.LXMinus,
			JOY_DPAD_RIGHT: GamepadAxisButton.LXPlus
		}
	}
	var maps = {
		"PS4 Controller": {
			"buttons": {
				JOY_SONY_X: GamepadButton.A,
				JOY_SONY_CIRCLE: GamepadButton.B,
				JOY_SONY_SQUARE: GamepadButton.X,
				JOY_SONY_TRIANGLE: GamepadButton.Y,
				JOY_START: GamepadButton.Start,
				JOY_L: GamepadButton.L1,
				JOY_L2: GamepadButton.L2,
				JOY_R: GamepadButton.R1,
				JOY_R2: GamepadButton.R2
			},
			"axis": {
				JOY_ANALOG_LX: GamepadAxis.LX,
				JOY_ANALOG_LY: GamepadAxis.LY
			},
			"axis_buttons": {
				JOY_DPAD_UP: GamepadAxisButton.LYMinus,
				JOY_DPAD_DOWN: GamepadAxisButton.LYPlus,
				JOY_DPAD_LEFT: GamepadAxisButton.LXMinus,
				JOY_DPAD_RIGHT: GamepadAxisButton.LXPlus
			}
		},
		"RetroLink Saturn Classic Controller": {
			"buttons": {
				JOY_BUTTON_1: GamepadButton.A,
				16: GamepadButton.B,
				JOY_BUTTON_0: GamepadButton.X,
				JOY_BUTTON_2: GamepadButton.Y,
				JOY_BUTTON_11: GamepadButton.Start,
				JOY_BUTTON_3: GamepadButton.L1,
				JOY_BUTTON_10: GamepadButton.R1,
			},
			"axis": {
				JOY_ANALOG_LX: GamepadAxis.LX,
				JOY_ANALOG_LY: GamepadAxis.LY
			},
			"axis_buttons": {
			}
		}
	}
	var loaded_maps = {}
	
	func make_map_for(id: int) -> GamepadInputMap:
		var name = Input.get_joy_name(id)
		var map = {}
		if loaded_maps.has(name):
			map = loaded_maps[name]
		elif maps.has(name):
			map = maps[name]
		elif Input.is_joy_known(id):
			map = DEFAULT_MAP
		else:
			return null
		var input_map = GamepadInputMap.new()
		input_map.load_from_dict(map)
		return input_map
	
	func load_maps():
		loaded_maps.clear()
		var file = File.new()
		if not file.file_exists(GAMEPAD_MAPS_FILE):
			return
		file.open(GAMEPAD_MAPS_FILE, File.READ)
		loaded_maps = parse_json(file.get_as_text())
		file.close()
	
	func save_maps():
		var file = File.new()
		file.open(GAMEPAD_MAPS_FILE, File.WRITE)
		var json = to_json(loaded_maps)
		file.store_line(json)
		file.close()


class Gamepad:
	var name := ""
	var guid := ""
	var id := -1
	var known := false
	var configured := false
	var input_map: GamepadInputMap
	
	func _init(gamepad_id: int = -1):
		id = gamepad_id
		if id >= 0:
			name = Input.get_joy_name(id)
			guid = Input.get_joy_guid(id)
			known = Input.is_joy_known(id)
	
	func set_input_map(map: GamepadInputMap):
		input_map = map
		configured = true


class GamepadState:
	var gamepad: Gamepad = null
	var buttons := {} # GamepadButton -> bool, pressed buttons
	var axis := {} # GamepadAxis -> float, axis values

	func _init(gp: Gamepad = null):
		gamepad = gp
		for button in range(GamepadButton.LAST):
			buttons[button] = false
		for ax in range(GamepadAxis.LAST):
			axis[ax] = 0.0

	func update():
		if gamepad and gamepad.configured:
			for button in range(GamepadButton.LAST):
				var button_id = gamepad.input_map.get_input_button_id(button)
				if button_id >= 0:
					buttons[button] = Input.is_joy_button_pressed(gamepad.id, button_id)
			for ax in range(GamepadAxis.LAST):
				axis[ax] = 0.0
				var axis_id = gamepad.input_map.get_input_axis_id(ax)
				if axis_id >= 0:
					axis[ax] = Input.get_joy_axis(gamepad.id, axis_id)
			for ax_button in range(GamepadAxisButton.LAST):
				var button_id = gamepad.input_map.get_axis_button_id(ax_button)
				if Input.is_joy_button_pressed(gamepad.id, button_id):
					var ax = GamepadAxisButtonValues[ax_button][0]
					var val = GamepadAxisButtonValues[ax_button][1]
					axis[ax] = val


var input_map_manager := InputMapManager.new()
var gamepads := {}
var gamepad_states := {}

signal gamepad_disconnected(device_id)
signal gamepad_connected(device_id)


func _ready():
	input_map_manager.load_maps()
	Input.connect("joy_connection_changed", self, "add_or_remove_gamepad")
	# Collect gamepads
	var id = 0
	while true:
		var name = Input.get_joy_name(id)
		if len(name) == 0:
			break
		add_gamepad(id)
		id += 1


func remove_gamepad(device_id: int):
	deactivate(device_id)
	if gamepads.has(device_id):
		gamepads.erase(device_id)


func add_gamepad(device_id: int):
	var gp = Gamepad.new(device_id)
	configure_gamepad(gp)
	gamepads[device_id] = gp


func add_or_remove_gamepad(device_id: int, was_connected: bool):
	if was_connected:
		print("Gamepad #" + str(device_id) + " connected")
		add_gamepad(device_id)
		emit_signal("gamepad_connected", device_id)
	else:
		print("Gamepad #" + str(device_id) + " disconnected")
		remove_gamepad(device_id)
		emit_signal("gamepad_disconnected", device_id)


func configure_gamepad(gp: Gamepad):
	var map: GamepadInputMap = input_map_manager.make_map_for(gp.id)
	if map:
		gp.set_input_map(map)


func is_configured(device_id: int) -> bool:
	if gamepads.has(device_id):
		return gamepads[device_id].configured
	return false


func activate(device_id: int) -> void:
	if gamepads.has(device_id):
		var state = GamepadState.new(gamepads[device_id])
		gamepad_states[device_id] = state


func deactivate(device_id: int) -> void:
	if gamepad_states.has(device_id):
		gamepad_states.erase(device_id)


func activate_all_configured():
	for gamepad_id in gamepads.keys():
		if gamepads[gamepad_id].configured:
			activate(gamepad_id)


func deactivate_all_except(ids_to_skip: Array) -> void:
	for gamepad_id in gamepads.keys():
		if ids_to_skip.find(gamepad_id) < 0:
			deactivate(gamepad_id)


func _process(_delta: float) -> void:
	for state in gamepad_states.values():
		state.update()


func get_axis(device_id: int, axis: int) -> float:
	if gamepad_states.has(device_id):
		return gamepad_states[device_id].axis.get(axis, 0.0)
	return 0.0


func get_button(device_id: int, button: int) -> bool:
	if gamepad_states.has(device_id):
		return gamepad_states[device_id].buttons.get(button, false)
	return false


func device_ids():
	var ids = []
	for id in gamepads.keys():
		ids.append(id)
	return ids


func active_device_ids():
	var ids = []
	for id in gamepad_states.keys():
		ids.append(id)
	return ids


func set_input_map_for(device_id: int, map: Dictionary) -> void:
	if not gamepads.has(device_id):
		return
	var gamepad: Gamepad = gamepads[device_id]
	var name = gamepad.name
	if len(name) == 0:
		return
	if map.size() == 0:
		if input_map_manager.loaded_maps.has(name):
			input_map_manager.loaded_maps.erase(name)
	else:
		input_map_manager.loaded_maps[name] = map
	configure_gamepad(gamepad)
