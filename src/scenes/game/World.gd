extends Node2D


func _ready() -> void:
	#Engine.time_scale = 0.5
	# Assign player #0 with controller #0D
	if GamepadManager.gamepads.size() > 0:
		GameInput.set_gamepad_input_source(0, 0)
	else:
		GameInput.set_keyboard_input_source(0)
	# Assign player #1 with controller #1
	if GamepadManager.gamepads.size() > 1:
		GameInput.set_gamepad_input_source(1, 1)
	else:
		GameInput.set_keyboard_input_source(1)
	# Alternative: assign keyboard controls (WSAD) to player #0
	# GameInput.set_keyboard_input_source(0)
	# Alternative: assign keyboard controls (↑↓←→) to player #1
	# GameInput.set_keyboard_input_source(1)
	$HudLayer/GameHUD/Characters/CharacterHUD1.set_name("5G-Вышка")
	$HudLayer/GameHUD/Characters/CharacterHUD2.set_name("Рептилоид")
	$HudLayer/GameHUD/Characters/CharacterHUD3.set_name("Масон")
	$HudLayer/GameHUD/Characters/CharacterHUD4.set_name("Пришелец")


func _process(delta: float) -> void:
	for i in [0, 1]:
		if GameInput.player(i).is_just_pressed(Constants.Actions.Pause):
			LoadingScene.run_scene("res://scenes/ui/MenuTest.tscn")
			set_process(false)
			return
	if Input.is_key_pressed(KEY_SPACE):
		var bot = $YSort/Mason
		if bot:
			bot.queue_free()
