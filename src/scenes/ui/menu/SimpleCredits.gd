extends Node2D

onready var anim_player = $AnimationPlayer

var hiding: bool = false

signal hidden()


func _ready() -> void:
	visible = false
	set_process(false)


func show() -> void:
	visible = true
	hiding = false
	set_process(true)
	anim_player.play("show")
	


func hide() -> void:
	set_process(false)
	hiding = true
	anim_player.play("hide")


func disable() -> void:
	visible = false
	emit_signal("hidden")


func _process(delta: float) -> void:
	if not hiding:
		if (GameInput.is_common_action_just_pressed(Constants.CommonActions.Enter) or
			GameInput.is_common_action_just_pressed(Constants.CommonActions.Esc)):
			hide()
