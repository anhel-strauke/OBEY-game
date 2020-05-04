extends CustomSlider


var new_game: bool = true setget set_new_game


var chars = []


func set_new_game(n: bool) -> void:
	if n:
		title_label.text = "Начать Игру"
	else:
		title_label.text = "Продолжить Игру"


func check_player_2(device: int) -> void:
	if device != -1:
		if not GameInput.player(1).input_source:
			if GamepadManager.gamepads.size() > 0:
				GamepadDetectionScene.allow_keyboard_fallback = true
				GamepadDetectionScene.player_index = 1
				GamepadDetectionScene.show_modal(self, "select_two_player")
			else:
				GameInput.set_keyboard_input_source(1)
				select_two_player(Constants.KeyboardDevice)
		else:
			select_two_player(Constants.KeyboardDevice)
		


func select_single_player(device) -> void:
	if device != -1:
		LoadingScene.run_scene("res://scenes/ui/character_selection/CharacterSelectionScene1.tscn")


func select_two_player(device) -> void:
	if device != -1:
		LoadingScene.run_scene("res://scenes/ui/character_selection/CharacterSelectionScene2.tscn")


func _on_SinglePlayer_activated():
	#LoadingScene.run_scene("res://scenes/game/World.tscn")
	if not GameInput.player(0).input_source:
		if GamepadManager.gamepads.size() > 0:
			GamepadDetectionScene.allow_keyboard_fallback = true
			GamepadDetectionScene.player_index = 0
			GamepadDetectionScene.show_modal(self, "select_single_player")
		else:
			GameInput.set_keyboard_input_source(0)
			select_single_player(Constants.KeyboardDevice)
	else:
		select_single_player(Constants.KeyboardDevice)


func _on_TwoPlayers_activated():
	chars = [Constants.Grayman, Constants.Tower5G]
	if not GameInput.player(0).input_source:
		if GamepadManager.gamepads.size() > 0:
			GamepadDetectionScene.allow_keyboard_fallback = true
			GamepadDetectionScene.player_index = 0
			GamepadDetectionScene.show_modal(self, "check_player_2")
		else:
			GameInput.set_keyboard_input_source(0)
			GameInput.set_keyboard_input_source(1)
			select_two_player(Constants.KeyboardDevice)
	else:
		check_player_2(Constants.KeyboardDevice)
