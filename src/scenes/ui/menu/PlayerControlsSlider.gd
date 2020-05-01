extends CustomSlider

var player_index: int = 0 setget set_player_index

onready var gamepad_config_item = $MenuSlider/Slider/MenuController/GamepadConfiguration


func set_player_index(index: int) -> void:
	player_index = index
	title_label.text = "Player " + str(index + 1)


func show() -> void:
	.show()
	var player = GameInput.player(player_index)
	if player.is_gamepad_input_source():
		menu_controller.current_index = 1
	gamepad_config_item.enabled = player.is_gamepad_input_source()


func _on_Keyboard_activated() -> void:
	GameInput.set_keyboard_input_source(player_index)
	hide()


func _on_Gamepad_activated() -> void:
	GamepadDetectionScene.player_index = player_index
	GamepadDetectionScene.do_detection = true
	GamepadDetectionScene.allow_keyboard_fallback = false
	GamepadDetectionScene.show_modal(self, "_on_Gamepad_detection_done")


func _on_Gamepad_detection_done(dev_id: int) -> void:
	if dev_id >= 0:
		GameInput.set_gamepad_input_source(player_index, dev_id)
		hide()


func _on_Gamepad_configuration_done(_dev_id: int) -> void:
	hide()


func _on_GamepadConfiguration_activated() -> void:
	GamepadDetectionScene.player_index = player_index
	GamepadDetectionScene.do_detection = false
	GamepadDetectionScene.allow_keyboard_fallback = false
	GamepadDetectionScene.show_modal(self, "_on_Gamepad_configuration_done")
