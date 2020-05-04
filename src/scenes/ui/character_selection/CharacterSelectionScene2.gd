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


func _ready() -> void:
	$AudioStreamPlayer.play()
	menu.players = 2
	for i in 2:
		if GameInput.player(i).is_keyboard_input_source():
			if i == 0:
				instruction_labels[i].text = "W и S = выбор, C = подтвердить, V или Esc = отмена"
			else:
				instruction_labels[i].text = "Стрелки = выбор, O = подтвердить, P или Esc = отмена"
		elif GameInput.player(i).is_gamepad_input_source():
			instruction_labels[i].text = "A = подтвердить выбор, B или Esc = отмена"
	menu.set_players(2)


func _on_CharactersMenu_selected(player, character):
	info[player].display_character(character)
	


func _on_CharactersMenu_cancelled():
	$AudioStreamPlayer.stop()
	LoadingScene.run_scene("res://scenes/ui/MenuTest.tscn")


func _on_CharactersMenu_finished_selection():
	var characters = [
		menu.selected_character_name(0),
		menu.selected_character_name(1)
	]
	$AudioStreamPlayer.stop()
	LoadingScene.run_game_arena(characters, "", "")
