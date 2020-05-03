extends "res://scenes/game/character/Weapons/Firearm.gd"


const MyBullet = preload("res://scenes/game/character/Weapons/projectiles/GunBullet.tscn")


func create_bullet() -> Node:
	return MyBullet.instance()
