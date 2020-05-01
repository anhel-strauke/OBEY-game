extends Node
class_name GamepadConfigurator

const AXIS_TRESHOLD = 0.7

const ButtonsToConfigure = [
	#  0 (is axis?)                1                            2                                         3
	[true,     GamepadManager.GamepadAxis.LY, GamepadManager.GamepadAxisButton.LYMinus, GamepadManager.GamepadAxisButton.LYPlus],
	[true,     GamepadManager.GamepadAxis.LX, GamepadManager.GamepadAxisButton.LXMinus, GamepadManager.GamepadAxisButton.LXPlus],
	[false,    GamepadManager.GamepadButton.A],
	[false,    GamepadManager.GamepadButton.B],
	[false,    GamepadManager.GamepadButton.X],
	[false,    GamepadManager.GamepadButton.Start]
]

enum State {
	Idle,
	WaitForAxis,
	GotAxis,
	WaitForAxisButton,
	WaitForButton,
	Finished,
	Cancelled
}

var state: int = State.Idle
var current_button_index := 0
var device_id := 0
export(bool) var enabled: bool = true setget set_enabled

var input_map := {}
var axis_triggered := []
var _used_axis = []
var _used_buttons = []

signal waiting_for_axis(axis)
signal waiting_for_axis_button(axis_button)
signal waiting_for_button(button)
signal finished()
signal cancelled()


func _process_current_button() -> void:
	if current_button_index >= len(ButtonsToConfigure):
		emit_signal("finished")
		return
	var task = ButtonsToConfigure[current_button_index]
	var is_axis: bool = task[0]
	if is_axis:
		if state == State.WaitForAxis:
			state = State.WaitForAxisButton
			emit_signal("waiting_for_axis_button", task[3])
		else:
			state = State.WaitForAxis
			emit_signal("waiting_for_axis", task[1])
	else:
		state = State.WaitForButton
		emit_signal("waiting_for_button", task[1])


func begin() -> void:
	state = State.Idle
	current_button_index = 0
	input_map = {
		"buttons": {},
		"axis": {},
		"axis_buttons": {}
	}
	_used_axis.clear()
	_used_buttons.clear()
	_process_current_button()


func store_axis_and_go_next(event):
	var task = ButtonsToConfigure[current_button_index]
	input_map["axis"][event.axis] = task[1]
	_used_axis.append(event.axis)
	state = State.GotAxis
	current_button_index += 1
	_process_current_button()


func _input(event) -> void:
	if event is InputEventKey:
		if event.is_pressed() and (event.scancode == KEY_ESCAPE or event.scancode == KEY_BACKSPACE):
			if state != State.Cancelled:
				state = State.Cancelled
				emit_signal("cancelled")
				return
	match state:
		State.WaitForAxis:
			if event is InputEventJoypadMotion:
				if event.device != device_id:
					return
				if event.axis_value > AXIS_TRESHOLD or event.axis_value < -AXIS_TRESHOLD:
					if axis_triggered.find(event.axis) < 0:
						if _used_axis.find(event.axis) < 0:
							store_axis_and_go_next(event)
						axis_triggered.append(event.axis)
				else:
					var index = axis_triggered.find(event.axis)
					if index >= 0:
						axis_triggered.remove(index)
			elif event is InputEventJoypadButton:
				if event.device != device_id:
					return
				if _used_buttons.find(event.button_index) >= 0:
					return
				if event.is_pressed():
					var task = ButtonsToConfigure[current_button_index]
					input_map["axis_buttons"][event.button_index] = task[2]
					_used_buttons.append(event.button_index)
					_process_current_button()
		State.WaitForAxisButton:
			if event is InputEventJoypadMotion:
				if event.device != device_id:
					return
				if event.axis_value > AXIS_TRESHOLD or event.axis_value < -AXIS_TRESHOLD:
					if axis_triggered.find(event.axis) < 0:
						if _used_axis.find(event.axis) < 0:
							store_axis_and_go_next(event)
						axis_triggered.append(event.axis)
				else:
					var index = axis_triggered.find(event.axis)
					if index >= 0:
						axis_triggered.remove(index)
			elif event is InputEventJoypadButton:
				if event.device != device_id:
					return
				if _used_buttons.find(event.button_index) >= 0:
					return
				if event.is_pressed():
					var task = ButtonsToConfigure[current_button_index]
					input_map["axis_buttons"][event.button_index] = task[3]
					current_button_index += 1
					_used_buttons.append(event.button_index)
					_process_current_button()
		State.WaitForButton:
			if event is InputEventJoypadButton:
				if event.device != device_id:
					return
				if _used_buttons.find(event.button_index) >= 0:
					return
				if event.is_pressed():
					var task = ButtonsToConfigure[current_button_index]
					input_map["buttons"][event.button_index] = task[1]
					current_button_index += 1
					_used_buttons.append(event.button_index)
					_process_current_button()


func set_enabled(en: bool) -> void:
	enabled = en
	set_process_input(enabled)
