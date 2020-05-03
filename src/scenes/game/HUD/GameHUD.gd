extends Node2D


onready var character_huds: Array = [
	$Characters/CharacterHUD1,
	$Characters/CharacterHUD2,
	$Characters/CharacterHUD3,
	$Characters/CharacterHUD4
]


func assign_character(ch: Character, index: int) -> void:
	if index >= 0 and index < character_huds.size():
		var hud = character_huds[index]
		ch.connect("health_changed", hud, "set_health")
		ch.connect("ammo_changed", hud, "set_ammo")
		hud.set_name(ch.display_name)
		hud.set_icon_index(ch.icon_index)
		hud.set_max_health(ch.max_hitpoints)
		hud.set_health(ch.max_hitpoints)
		hud.set_ammo(0)
