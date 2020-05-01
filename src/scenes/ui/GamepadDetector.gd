extends Node
class_name GamepadDetector

const AXIS_TRESHOLD: float = 0.7

export(bool) var enabled: bool = false setget set_enabled

signal gamepad_detected(device_id)

func _input(event) -> void:
	if not enabled:
		return
	if event is InputEventJoypadMotion:
		if event.axis_value > AXIS_TRESHOLD or event.axis_value < -AXIS_TRESHOLD:
			self.enabled = false
			emit_signal("gamepad_detected", event.device)
	elif event is InputEventJoypadButton:
		if event.is_pressed():
			self.enabled = false
			emit_signal("gamepad_detected", event.device)


func set_enabled(en: bool) -> void:
	enabled = en
	set_process_input(enabled)
