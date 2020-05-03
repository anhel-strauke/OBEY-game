extends Node2D
class_name BaseWeapon

signal picked_up(name)

export(bool) var is_firearm: bool = true
export(float) var attack_cooldown_time: float = 0.5
export(bool) var is_automatic: bool = false
export(float) var hit_damage: float = 1.0
export(float) var knockback_impulse: float = 120.0

var owner_name: String

var attack_cooldown: float = 0.0


func can_attack(was_pressed: bool) -> bool:
	return (is_automatic or not was_pressed) and attack_cooldown <= 0.0


func _process(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

func signal_picked_up():
	emit_signal("picked_up", name)
