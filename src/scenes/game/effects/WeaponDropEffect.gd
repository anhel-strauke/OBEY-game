extends Node2D

onready var rot_point = $WeaponPivot/WeaponRotationPivot

func set_weapon(weapon: Node2D) -> void:
	var parent = weapon.get_parent()
	if parent:
		parent.remove_child(weapon)
	rot_point.add_child(weapon)
	weapon.position = Vector2.ZERO
