extends Node2D
class_name WeaponSpawner

export(String, FILE, "*.tscn") var weapon_scene: String = "" 
export(float) var spawn_period: float = 20

onready var Weapon = load(weapon_scene)

var _spawn_timer: float = 0.0


func _ready() -> void:
	$Polygon2D.visible = false


func _process(delta: float) -> void:
	if not Weapon:
		return
	var weapon_found = false
	for child in get_children():
		if child is BaseWeapon:
			weapon_found = true
			break
	if not weapon_found:
		_spawn_timer -= delta
		if _spawn_timer <= 0:
			var new_weapon = Weapon.instance()
			add_child(new_weapon)
			new_weapon.position = Vector2.ZERO
			_spawn_timer = spawn_period