extends Node2D


onready var info = $CharacterInformation
onready var instructions_label = $InstructionsLabel
onready var menu = $CharactersMenu


func _ready():
	if GameInput.player(0).is_keyboard_input_source():
		instructions_label.text = "W и S = выбор, C = подтвердить, V или Esc = отмена"
	elif GameInput.player(0).is_gamepad_input_source():
		instructions_label.text = "A = подтвердить выбор, B или Esc = отмена"
	menu.set_players(1)


func _on_CharactersMenu_selected(player, character):
	info.display_character(character)


func _on_CharactersMenu_cancelled():
	LoadingScene.run_scene("res://scenes/ui/MenuTest.tscn")


func _on_CharactersMenu_finished_selection():
	var characters = [
		menu.selected_character_name(0)
	]
	LoadingScene.run_game_arena(characters, "res://scenes/game/arenas/Arena1.tscn", "")
