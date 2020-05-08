extends Node2D


func _ready():
	if not GameInput.player(0).input_source:
		GameInput.set_keyboard_input_source(0)
	LoadingScene.run_game_arena(["Reptiloid"], "", "")
