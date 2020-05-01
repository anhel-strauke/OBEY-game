extends Node2D
class_name MenuItem

onready var anim_player = $AnimationPlayer
onready var click_sound = $ClickSound
onready var activation_sound = $ActivationSound
export(bool) var enabled := true setget set_enabled

var selected := false setget set_selected

signal activated()
signal selected()
signal deselected()


func set_enabled(en: bool) -> void:
	enabled = en
	var color = Color(1.0, 1.0, 1.0, 1.0)
	if not enabled:
		color = Color(1.0, 1.0, 1.0, 0.4)
	modulate = color


func _play_selection_anim(forward: bool) -> void:
	if anim_player.is_playing():
		anim_player.stop(false)
		if forward:
			anim_player.play("slide")
		else:
			anim_player.play_backwards("slide")
	else:
		if forward:
			anim_player.play("slide")
		else:
			anim_player.play_backwards("slide")


func set_selected(sel: bool) -> void:
	if selected != sel:
		selected = sel
		_play_selection_anim(selected)
		if selected:
			click_sound.play()
			emit_signal("selected")
		else:
			emit_signal("deselected")


func set_selected_immed(sel: bool) -> void:
	selected = sel
	var anim: Animation = anim_player.get_animation("slide")
	var length = anim.length
	if selected:
		anim_player.play("slide")
		anim_player.seek(length, true)
		anim_player.stop(false)
		emit_signal("selected")
	else:
		anim_player.play("slide")
		anim_player.seek(0.0, true)
		anim_player.stop(false)
		emit_signal("deselected")


func activate() -> void:
	activation_sound.play()
	emit_signal("activated")

