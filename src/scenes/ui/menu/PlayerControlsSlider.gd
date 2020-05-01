extends CustomSlider

var player_index: int = 0 setget set_player_index

onready var gamepad_config_item = $MenuSlider/Slider/MenuController/GamepadConfiguration

func set_player_index(index: int) -> void:
	player_index = index
	title_label.text = "Player " + str(index + 1)


func show():
	.show()
	var player = GameInput.player(player_index)
	if player.is_gamepad_input_source():
		menu_controller.current_index = 1
	gamepad_config_item.enabled = player.is_gamepad_input_source()


func _on_Keyboard_activated():
	GameInput.set_keyboard_input_source(player_index)
	hide()


func _on_Gamepad_activated():
	GameInput.set_gamepad_input_source(player_index, 0)
	hide()
