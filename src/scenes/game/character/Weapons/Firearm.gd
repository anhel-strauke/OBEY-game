extends BaseWeapon


const Bullet = preload("res://scenes/game/character/Weapons/Bullet.tscn")
onready var bullet_spawn = $BulletSpawn

export(int) var ammo: int = 5

var _current_ammo: int = 0

signal out_of_ammo()


func _ready() -> void:
	_current_ammo = ammo


func find_bullet_parent() -> Node2D:
	var nodes = get_tree().get_nodes_in_group("BulletParent")
	if nodes.size() > 0:
		return nodes[0]
	return null


func do_fire(direction: Vector2):
	if _current_ammo == 0:
		emit_signal("out_of_ammo")
		return
	_current_ammo -= 1
	var parent = find_bullet_parent()
	var projectile = Bullet.instance()
	projectile.gunslinger_name = owner_name
	projectile.direction_vector = direction
	projectile.global_position = bullet_spawn.global_position
	parent.add_child(projectile)
	attack_cooldown = attack_cooldown_time
