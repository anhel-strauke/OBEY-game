extends Node2D


onready var menu = $CharactersMenu
onready var info = [
	$CharacterInformation,
	$CharacterInformation2
]
onready var instruction_labels = [
	$Label,
	$Label2
]

var bg_music = preload("res://sounds/music/ArenaP.ogg")

func _ready() -> void:
	BackgroundMusic.set_with_fade(bg_music)
	menu.players = 2
	for i in 2:
		if GameInput.player(i).is_keyboard_input_source():
			if i == 0:
				instruction_labels[i].text = "W и S = выбор,\nC = подтвердить,\nV или Esc = отмена"
			else:
				instruction_labels[i].text = "Стрелки = выбор,\nO = подтвердить,\nP или Esc = отмена"
		elif GameInput.player(i).is_gamepad_input_source():
			instruction_labels[i].text = "Вверх и Вниз = выбор,\n(A) = подтвердить выбор,\n(B) или Esc = отмена"
	menu.set_players(2)


func _on_CharactersMenu_selected(player, character):
	info[player].display_character(character)


func _on_CharactersMenu_cancelled():
	BackgroundMusic.stop_with_fade()
	LoadingScene.run_scene("res://scenes/ui/MenuTest.tscn")


func _on_CharactersMenu_finished_selection():
	var characters = [
		menu.selected_character_name(0),
		menu.selected_character_name(1)
	]
	BackgroundMusic.stop_with_fade()
	LoadingScene.run_game_arena(characters, "", "")
