extends BaseWeapon


const Bullet = preload("res://scenes/game/character/Weapons/Bullet.tscn")
onready var bullet_spawn = $BulletSpawn
onready var shoot_anim = $ShotAnim

export(int) var ammo: int = 5
export(float) var bullet_speed: float = 30.0
export(float) var bullet_friction: float = 12.0

export(AudioStream) var shoot_sound = null

var _current_ammo: int = 0

signal out_of_ammo()


func _ready() -> void:
	_current_ammo = ammo


func find_bullet_parent() -> Node2D:
	var nodes = get_tree().get_nodes_in_group("BulletParent")
	if nodes.size() > 0:
		return nodes[0]
	return null


func create_bullet() -> Node:
	return Bullet.instance()


func setup_projectile(projectile) -> void:
	projectile.gunslinger_name = owner_name
	projectile.set_sound(shoot_sound)
	projectile.global_position = bullet_spawn.global_position
	projectile.damage = hit_damage
	projectile.impulse = knockback_impulse


func make_shot(direction: Vector2, parent: Node) -> void:
	var projectile = create_bullet()
	setup_projectile(projectile)
	projectile.direction_vector = direction
	parent.add_child(projectile)


func do_fire(direction: Vector2):
	if _current_ammo == 0:
		emit_signal("out_of_ammo")
		return
	_current_ammo -= 1
	var parent = find_bullet_parent()
	make_shot(direction, parent)
	attack_cooldown = attack_cooldown_time
	if shoot_anim:
		print("Playing shoot")
		shoot_anim.play("shoot")
