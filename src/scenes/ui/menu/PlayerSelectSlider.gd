extends CustomSlider


var new_game: bool = true setget set_new_game


func set_new_game(n: bool) -> void:
	if n:
		title_label.text = "Начать Игру"
	else:
		title_label.text = "Продолжить Игру"



func _on_SinglePlayer_activated():
	LoadingScene.run_scene("res://scenes/game/World.tscn")
