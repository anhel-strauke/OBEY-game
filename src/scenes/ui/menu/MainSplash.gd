extends Node2D


var active: bool = false
onready var button = $ItemBack
onready var anim_player = $AnimationPlayer
onready var sound = $CloseSound


signal finished()


func _ready():
	visible = false


func activate_input():
	button.visible = true
	active = true


func run():
	visible = true
	active = false
	anim_player.play("show")


func finish():
	visible = false
	emit_signal("finished")


func _hide():
	active = false
	button.hide()
	anim_player.play("hide")
	sound.play()


func _input(event):
	if not active:
		return
	if event is InputEventKey:
		if event.is_pressed():
			_hide()
	elif event is InputEventJoypadButton:
		if event.is_pressed():
			_hide()
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.6:
			_hide()
