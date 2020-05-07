extends Node2D
class_name GameHUD


enum PlayerDeathState {
	MovingDown,
	MovingUp,
	TopPosition,
	BottomPosition
}

onready var character_huds: Array = [
	$Characters/CharacterHUD1,
	$Characters/CharacterHUD2,
	$Characters/CharacterHUD3,
	$Characters/CharacterHUD4
]

onready var start_anim = $StartMessages/AnimationPlayer
onready var victory_anim = $VictoryMessage/AnimationPlayer
onready var victory_label = $VictoryMessage/Label
onready var player_death_label = $PlayerDeathMessage/PlayerDeathLabel
onready var player_death_anim = $PlayerDeathMessage/AnimationPlayer

var player_death_state = PlayerDeathState.TopPosition
var dead_player_characters = [false, false] setget set_dead_player_characters
var current_dead_player_characters = [false, false]

signal start_animation_finished()
signal victory_animation_finished()


func assign_character(ch: Character, index: int) -> void:
	if index >= 0 and index < character_huds.size():
		var hud = character_huds[index]
		ch.connect("health_changed", hud, "set_health")
		ch.connect("ammo_changed", hud, "set_ammo")
		ch.connect("died", hud, "display_death")
		hud.set_dead(false)
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


func _update_dead_player_characters():
	current_dead_player_characters = dead_player_characters
	if not dead_player_characters[0] and not dead_player_characters[1]:
		player_death_label.text = ""
	elif dead_player_characters[0] and not dead_player_characters[1]:
		player_death_label.text = "Игрок 1 всё"
	elif not dead_player_characters[0] and dead_player_characters[1]:
		player_death_label.text = "Игрок 2 всё"
	else:
		player_death_label.text = "Оба игрока всё"


func set_dead_player_characters(dead: Array) -> void:
	if dead != dead_player_characters:
		dead_player_characters = dead
		match player_death_state:
			PlayerDeathState.TopPosition:
				_player_death_go_down()
			PlayerDeathState.BottomPosition:
				_player_death_go_up()


func _player_death_go_down() -> void:
	_update_dead_player_characters()
	if current_dead_player_characters[0] or current_dead_player_characters[1]:
		player_death_state = PlayerDeathState.MovingDown
		player_death_anim.play("show")
	else:
		player_death_state = PlayerDeathState.TopPosition


func _player_death_go_up() -> void:
	if dead_player_characters != current_dead_player_characters:
		player_death_state = PlayerDeathState.MovingUp
		player_death_anim.play("hide")
	else:
		player_death_state = PlayerDeathState.BottomPosition
