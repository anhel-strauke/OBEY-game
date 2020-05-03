extends "res://scenes/game/character/Weapons/Firearm.gd"

const MyBullet = preload("res://scenes/game/character/Weapons/projectiles/ShotgunBullet.tscn")

export(float) var bullet_speed_range: float = 1.5
export(float) var bullet_spread_degree: float = 4
export(int) var bullets_number: int = 5

func create_bullet() -> Node:
	return MyBullet.instance()


func setup_projectile(projectile) -> void:
	.setup_projectile(projectile)
	projectile.set_sound(null)
	projectile.speed = rand_range(bullet_speed - bullet_speed_range, bullet_speed + bullet_speed_range)
	projectile.friction = bullet_friction


func _make_spread_angles() -> Array:
	if bullets_number <= 1:
		return [0.0]
	var angles = []
	var step = bullet_spread_degree * 2.0 / (bullets_number - 1)
	for i in bullets_number:
		var angle = -bullet_spread_degree + i * step
		angles.append(angle)
	return angles

func make_shot(direction: Vector2, parent: Node) -> void:
	var first_projectile = true
	
	for angle in _make_spread_angles():
		var projectile = create_bullet()
		setup_projectile(projectile)
		# We need only 1 sound, so only first projectile makes it
		if first_projectile:
			projectile.set_sound(shoot_sound)
			make_flash(projectile, parent)
			first_projectile = false
		var phi: float = deg2rad(angle)
		projectile.direction_vector = direction.rotated(phi)
		parent.add_child(projectile)

