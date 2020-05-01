extends Node2D

const KBD_FALLBACK_KEY = [
	[KEY_H, "H"],
	[KEY_P, "P"]
]

const PLEASE_PRESS = "Please press %s on the gamepad"

enum State {
	Showing,
	DetectingGamepad,
	ConfiguringGamepad,
	SuccessMessage,
	Hiding
}

signal success()
signal cancelled()

onready var anim_player = $AnimationPlayer
onready var detection_controls = $ControlsRoot/Detection
onready var configuring_controls = $ControlsRoot/Configuring
onready var player_label = $ControlsRoot/Player
onready var unknown_gp_message = $ControlsRoot/Configuring/UnknownMessage
onready var just_configuring_message = $ControlsRoot/Configuring/JustConfiguringMessage
onready var prompt_label = $ControlsRoot/Configuring/Prompt
onready var kbd_fallback_label = $ControlsRoot/Detection/KbdFallbackMessage
onready var cancel_guide = $ControlsRoot/CancelGuide
onready var success_message = $ControlsRoot/Success
onready var configurator = $GamepadConfigurator
onready var detector = $GamepadDetector

var player_index: int = 0 setget set_player_index
var device_id = -1
var do_detection: bool = true
var allow_keyboard_fallback: bool = false
var state = State.Showing
var _success_time = 0.0


var cancelled: bool = false

func _ready():
	detector.enabled = false
	configurator.enabled = false
	GamepadManager.connect("gamepad_disconnected", self, "on_gamepad_disconnected")
	show()


func set_player_index(index: int) -> void:
	player_index = index
	player_label.text = "Player %d" % (player_index + 1)
	kbd_fallback_label.text = "or press %s to use keyboard controls" % KBD_FALLBACK_KEY[player_index][1]


func show() -> void:
	global_position = Vector2.ZERO
	cancelled = false
	state = State.Showing
	detector.enabled = false
	configurator.enabled = false
	success_message.visible = false
	cancel_guide.visible = true
	if do_detection:
		configuring_controls.visible = false
		detection_controls.visible = true
		kbd_fallback_label.visible = allow_keyboard_fallback
	else:
		configuring_controls.visible = true
		detection_controls.visible = false
		just_configuring_message.visible = true
		unknown_gp_message.visible = false
		prompt_label.text = ""
	anim_player.play("show")


func hide() -> void:
	detector.enabled = false
	configurator.enabled = false
	anim_player.play("hide")


func begin_gamepad_detection() -> void:
	state = State.DetectingGamepad
	configurator.enabled = false
	detector.enabled = true


func begin_gamepad_configuration() -> void:
	state = State.ConfiguringGamepad
	detector.enabled = false
	configurator.enabled = true
	configurator.device_id = device_id
	configurator.begin()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "show":
		if do_detection:
			begin_gamepad_detection()
		else:
			begin_gamepad_configuration()
	else:
		if cancelled:
			emit_signal("cancelled")
		else:
			emit_signal("success")


func _on_gamepad_detected(device_id: int) -> void:
	GameInput.set_gamepad_input_source(player_index, device_id)
	self.device_id = device_id
	if GamepadManager.is_configured(device_id):
		cancelled = false
		hide()
	else:
		detection_controls.visible = false
		configuring_controls.visible = true
		just_configuring_message.visible = false
		unknown_gp_message.visible = true
		begin_gamepad_configuration()


func on_gamepad_disconnected(device_id: int) -> void:
	if state == State.ConfiguringGamepad or state == State.SuccessMessage:
		if device_id == self.device_id:
			if do_detection:
				success_message.visible = false
				configuring_controls.visible = false
				detection_controls.visible = true
				begin_gamepad_detection()
			else:
				configurator.enabled = false
				cancelled = true
				hide()


func _input(event) -> void:
	match state:
		State.DetectingGamepad:
			if event is InputEventKey:
				if event.is_pressed():
					if event.scancode == KEY_ESCAPE or event.scancode == KEY_BACKSPACE:
						cancelled = true
						detector.enabled = false
						hide()
					elif allow_keyboard_fallback and event.scancode == KBD_FALLBACK_KEY[player_index][0]:
						cancelled = false
						GameInput.set_keyboard_input_source(player_index)
						hide()
		State.SuccessMessage:
			if _success_time <= 0.0:
				if event is InputEventJoypadButton:
					if event.device == device_id and event.is_pressed():
						cancelled = false
						hide()


func _process(delta: float) -> void:
	if state == State.SuccessMessage and _success_time > 0.0:
		_success_time -= delta


func _on_GamepadConfigurator_cancelled():
	cancelled = true
	hide()


func _on_GamepadConfigurator_finished():
	cancelled = false
	if device_id >= 0:
		var input_map = configurator.input_map
		GamepadManager.set_input_map_for(device_id, input_map)
	configuring_controls.visible = false
	success_message.visible = true
	cancel_guide.visible = false
	configurator.enabled = false
	_success_time = 0.5
	state = State.SuccessMessage


func _on_GamepadConfigurator_waiting_for_axis(axis):
	var axis_text = "Left"
	if axis == GamepadManager.GamepadAxis.LY:
		axis_text = "Up"
	prompt_label.text = PLEASE_PRESS % axis_text


func _on_GamepadConfigurator_waiting_for_axis_button(axis_button):
	var button_text = ""
	match axis_button:
		GamepadManager.GamepadAxisButton.LXMinus:
			button_text = "Left"
		GamepadManager.GamepadAxisButton.LXPlus:
			button_text = "Right"
		GamepadManager.GamepadAxisButton.LYMinus:
			button_text = "Up"
		GamepadManager.GamepadAxisButton.LYPlus:
			button_text = "Down"
	prompt_label.text = PLEASE_PRESS % button_text


func _on_GamepadConfigurator_waiting_for_button(button):
	var button_text = ""
	match button:
		GamepadManager.GamepadButton.A:
			button_text = "A button"
		GamepadManager.GamepadButton.B:
			button_text = "B button"
		GamepadManager.GamepadButton.X:
			button_text = "X button"
		GamepadManager.GamepadButton.Y:
			button_text = "Y button"
		GamepadManager.GamepadButton.Start:
			button_text = "Start"
		GamepadManager.GamepadButton.L1:
			button_text = "L1"
		GamepadManager.GamepadButton.L2:
			button_text = "L2"
		GamepadManager.GamepadButton.R1:
			button_text = "R1"
		GamepadManager.GamepadButton.R2:
			button_text = "R2"
	prompt_label.text = PLEASE_PRESS % button_text
