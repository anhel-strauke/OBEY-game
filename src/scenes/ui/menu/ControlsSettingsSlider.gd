extends CustomSlider


onready var player_slider = $MenuSlider/Slider/PlayerControlsSlider
onready var player_input_labels = [
	$MenuSlider/Slider/MenuController/Player1/Value,
	$MenuSlider/Slider/MenuController/Player2/Value
]

func _ready():
	attach_slider(player_slider)
	GameInput.connect("player_controls_changed_to_gamepad", self, "update_to_gamepad")
	GameInput.connect("player_controls_changed_to_keyboard", self, "update_to_keyboard")


func set_input_src_label(player_index: int) -> void:
	var player = GameInput.player(player_index)
	var text = "???"
	if player.is_keyboard_input_source():
		text = "Клавиатура"
	elif player.is_gamepad_input_source():
		var gp_id = player.input_source.device_id
		text = "Геймпад №%d" % gp_id
	player_input_labels[player_index].text = text


func show():
	set_input_src_label(0)
	set_input_src_label(1)
	.show()


func update_to_keyboard(player_index: int) -> void:
	player_input_labels[player_index].text = "Клавиатура"


func update_to_gamepad(player_index: int) -> void:
	var player = GameInput.player(player_index)
	var gamepad_id_str = "?"
	if player.is_gamepad_input_source():
		var id = player.input_source.device_id
		gamepad_id_str = str(id)
	player_input_labels[player_index].text = "Геймпад №%s" % gamepad_id_str


func _on_Player1_activated():
	player_slider.player_index = 0
	activate_slider(player_slider)


func _on_Player2_activated():
	player_slider.player_index = 1
	activate_slider(player_slider)
