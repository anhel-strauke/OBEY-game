extends "res://scenes/game/character/Weapons/Firearm.gd"

const MyBullet = preload("res://scenes/game/character/Weapons/projectiles/ShotgunBullet.tscn")


func create_bullet() -> Node:
	return MyBullet.instance()


func setup_projectile(projectile) -> void:
	.setup_projectile(projectile)
	projectile.set_sound(null)
	projectile.speed = rand_range(20.0, 23.0)
	projectile.friction = 14.0


func make_shot(direction: Vector2, parent: Node) -> void:
	var first_projectile = true
	for angle in [-4, -2, 0, 2, 4]:
		var projectile = create_bullet()
		setup_projectile(projectile)
		# We need only 1 sound, so only first projectile makes it
		if first_projectile:
			projectile.set_sound(shoot_sound)
			first_projectile = false
		var phi: float = deg2rad(angle)
		projectile.direction_vector = direction.rotated(phi)
		parent.add_child(projectile)

