extends Node2D


onready var anim_player = $AnimationPlayer

export(String, FILE, "*.tscn") var next_scene = ""
export(float) var SKIP_TO_POSITION = 3.6

var _can_skip = true


func skip() -> void:
	_can_skip = false
	anim_player.seek(SKIP_TO_POSITION, true)


func load_next_scene() -> void:
	if len(next_scene) > 0:
		get_tree().change_scene(next_scene)


func _input(event: InputEvent) -> void:
	if _can_skip:
		if event is InputEventKey:
			var key_event = event as InputEventKey
			if key_event.is_pressed():
				skip()
		elif event is InputEventJoypadButton:
			var joy_event = event as InputEventJoypadButton
			if joy_event.is_pressed():
				skip()


func _process(delta: float) -> void:
	if _can_skip:
		if anim_player.is_playing():
			if anim_player.current_animation_position >= SKIP_TO_POSITION:
				_can_skip = false
