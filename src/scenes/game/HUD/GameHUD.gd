extends Node2D
class_name GameHUD


onready var character_huds: Array = [
	$Characters/CharacterHUD1,
	$Characters/CharacterHUD2,
	$Characters/CharacterHUD3,
	$Characters/CharacterHUD4
]

onready var start_anim = $StartMessages/AnimationPlayer
onready var victory_anim = $VictoryMessage/AnimationPlayer
onready var victory_label = $VictoryMessage/Label

signal start_animation_finished()
signal victory_animation_finished()


func assign_character(ch: Character, index: int) -> void:
	if index >= 0 and index < character_huds.size():
		var hud = character_huds[index]
		ch.connect("health_changed", hud, "set_health")
		ch.connect("ammo_changed", hud, "set_ammo")
		hud.set_name(ch.display_name)
		hud.set_icon_index(ch.icon_index)
		hud.set_max_health(ch.max_hitpoints)
		hud.set_health(ch.max_hitpoints)
		hud.set_ability_cooldown_max(1.0)
		hud.set_ability_cooldown(1.0)
		hud.set_ammo(0)


func start_animation() -> void:
	start_anim.play("start_sequence")


func _on_start_animation_end() -> void:
	emit_signal("start_animation_finished")


func victory_message(winner_name: String):
	if len(winner_name) > 0:
		victory_label.text = "%s ПОБЕЖДАЕТ!" % winner_name
	else:
		victory_label.text = "НИЧЬЯ"
	victory_anim.play("show_message")


func _on_victory_animation_end() -> void:
	emit_signal("victory_animation_finished")
