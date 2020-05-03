extends Node2D
class_name CharacterHUD


onready var health_anim: AnimationPlayer = $HealthAnimation
onready var ammo_anim: AnimationPlayer = $AmmoAnimation
onready var name_label: Label = $Name
onready var portrait_parent: Node2D = $CharacterPortraitParent

var max_health: float = 100.0 setget set_max_health


func set_max_health(value: float) -> void:
	max_health = value


func _set_animation_value(player: AnimationPlayer, name: String, value: float) -> void:
	player.play(name)
	player.seek(value, true)
	player.stop(false)


func set_ammo(num: int) -> void:
	_set_animation_value(ammo_anim, "set_ammo", num)


func set_health(value: float) -> void:
	var clamped = clamp(value / max_health, 0.0, 1.0)
	_set_animation_value(health_anim, "set_health", clamped)


func set_name(name: String) -> void:
	name_label.text = name


func set_icon_index(index: int) -> void:
	pass
