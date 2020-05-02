extends Node2D


onready var cancel_sound = $CancelSound
onready var anim_player = $SlideAnimationPlayer
onready var menu_controller = $Slider/MenuController
onready var back_label = $Slider/BackLabel
onready var back_label_pos = back_label.position

signal hidden()
signal showing()

enum State {
	Hidden,
	SlideIn,
	SlideOut,
	Running
}

var state = State.Hidden setget set_state


func show() -> void:
	#back_label.position = Vector2(back_label_pos.x - get_parent().position.x, back_label_pos.y)
	self.state = State.SlideIn
	menu_controller.set_current_index(0)
	anim_player.play("slide_in")


func hide() -> void:
	self.state = State.SlideOut
	cancel_sound.play()
	anim_player.play("slide_out")


func _on_SlideAnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "slide_in":
		self.state = State.Running
		emit_signal("showing")
	elif anim_name == "slide_out":
		self.state = State.Hidden
		emit_signal("hidden")


func set_state(st: int) -> void:
	state = st
	menu_controller.set_enabled(state == State.Running)
	if state == State.Running:
		GameInput.set_common_input_mode(true)
		


func _on_MenuController_cancelled() -> void:
	hide()
