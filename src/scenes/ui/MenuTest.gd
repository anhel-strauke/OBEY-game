extends Node2D

onready var menu_controller = $MenuController
onready var player_selection = $PlayerSelectSlider
onready var settings = $SettingsSlider
onready var main_splash = $MainSplash


func _ready() -> void:
	GameInput.set_common_input_mode(true)
	if Global.game_just_started:
		menu_controller.enabled = false
		main_splash.visible = true
		main_splash.run()
		Global.game_just_started = false
	else:
		menu_controller.enabled = true

func _activate_slider(slider):
	menu_controller.enabled = false
	slider.visible = true
	slider.show()


func _on_Exit_activated():
	get_tree().quit()


func _on_NewGame_activated():
	player_selection.new_game = true
	_activate_slider(player_selection)


func _on_slider_hidden():
	menu_controller.enabled = true


func _on_Settings_activated():
	_activate_slider(settings)


func _on_MainSplash_finished():
	menu_controller.enabled = true
