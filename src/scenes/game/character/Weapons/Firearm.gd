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
signal ammo_changed(ammo)


func _ready() -> void:
	_current_ammo = ammo


func create_bullet() -> Node:
	return Bullet.instance()


#func setup_projectile(projectile) -> void:
#	projectile.gunslinger_name = owner_name
#	projectile.set_sound(shoot_sound)
#	projectile.global_position = bullet_spawn.global_position
#	projectile.damage = hit_damage
#	projectile.impulse = knockback_impulse
#
#	# position viewport correction:
#	var vp = get_parent()
#	while not vp is Viewport:
#		vp = vp.get_parent()
#	projectile.global_position += vp.get_parent().global_position - Vector2(150, 200)


func setup_projectile(projectile) -> void:
	projectile.gunslinger_name = owner_name
	projectile.set_sound(shoot_sound)
	projectile.damage = hit_damage
	projectile.impulse = knockback_impulse

#	position viewport correction:
#	var root = get_tree().get_root()
#	var cur_node = self
#	var msg_text = "Positions:\n"
#	while cur_node != root:
#		msg_text += cur_node.name + ": "
#		if not cur_node.get('global_position'):
#		msg_text += "no global_position"
#	else:
#		msg_text += "x=" + str(cur_node.global_position.x) + ", y=" + str(cur_node.global_position.y)
#	msg_text += "\n"
#	cur_node = cur_node.get_parent()
#	root.get_node("World").get_node("Label").text = msg_text
	var vp = get_parent().get_parent().get_parent()
	projectile.global_position = bullet_spawn.global_position + vp.get_parent().global_position - Vector2(150, 200)


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
	emit_signal("ammo_changed", _current_ammo)
	var parent = Global.find_bullet_parent()
	make_shot(direction, parent)
	attack_cooldown = attack_cooldown_time
	if shoot_anim:
		print("Playing shoot")
		shoot_anim.play("shoot")
