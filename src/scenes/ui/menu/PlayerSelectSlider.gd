extends CustomSlider


var new_game: bool = true setget set_new_game


func set_new_game(n: bool) -> void:
	if n:
		title_label.text = "New Game"
	else:
		title_label.text = "Continue Game"
