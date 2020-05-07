extends CustomSlider


var new_game: bool = true setget set_new_game
var players_count = 1
var next_player = 1

onready var controls_setting_anim = $MenuSlider/Slider/GamepadSettingBg/AnimationPlayer


func set_new_game(n: bool) -> void:
	if n:
		title_label.text = "Начать Игру"
	else:
		title_label.text = "Продолжить Игру"


func check_player_2(device: int) -> void:
	if device != -1:
		print("Checking Player 2")
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
	else:
		controls_setting_anim.play("hide")


func select_single_player(device) -> void:
	if device != -1:
		LoadingScene.run_scene("res://scenes/ui/character_selection/CharacterSelectionScene1.tscn")
	else:
		controls_setting_anim.play("hide")


func select_two_player(device) -> void:
	if device != -1:
		LoadingScene.run_scene("res://scenes/ui/character_selection/CharacterSelectionScene2.tscn")
	else:
		controls_setting_anim.play("hide")


func _on_SinglePlayer_activated() -> void:
	#LoadingScene.run_scene("res://scenes/game/World.tscn")
	if not GameInput.player(0).input_source:
		if GamepadManager.gamepads.size() > 0:
			players_count = 1
			next_player = 1
			controls_setting_anim.play("show")
		else:
			GameInput.set_keyboard_input_source(0)
			select_single_player(Constants.KeyboardDevice)
	else:
		select_single_player(Constants.KeyboardDevice)


func _on_TwoPlayers_activated() -> void:
	players_count = 2
	if not GameInput.player(0).input_source:
		if GamepadManager.gamepads.size() > 0:
			next_player = 1
			controls_setting_anim.play("show")
		else:
			GameInput.set_keyboard_input_source(0)
			GameInput.set_keyboard_input_source(1)
			select_two_player(Constants.KeyboardDevice)
	else:
		next_player = 2
		controls_setting_anim.play("show")


func _on_GamepadSettingBg_animation_finished(anim_name: String) -> void:
	if anim_name == "show":
		GamepadDetectionScene.allow_keyboard_fallback = true
		GamepadDetectionScene.player_index = 0
		if players_count == 1:
			GamepadDetectionScene.show_modal(self, "select_single_player")
		elif next_player == 1:
			GamepadDetectionScene.show_modal(self, "check_player_2")
		else:
			check_player_2(Constants.KeyboardDevice)
