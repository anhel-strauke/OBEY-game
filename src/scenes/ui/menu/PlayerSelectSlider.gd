extends CustomSlider


var new_game: bool = true setget set_new_game


func set_new_game(n: bool) -> void:
	if n:
		title_label.text = "Start Game"
	else:
		title_label.text = "Continue Game"



func _on_SinglePlayer_activated():
	LoadingScene.run_scene("res://scenes/game/World.tscn")
