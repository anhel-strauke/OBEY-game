extends WeaponSpawner


const weapon_scenes = [
	preload("res://scenes/game/character/Weapons/Gun.tscn"),
	preload("res://scenes/game/character/Weapons/AssaultRifle.tscn"),
	preload("res://scenes/game/character/Weapons/Shotgun.tscn")
]


export(float) var gun_probability = 1.0
export(float) var assault_rifle_probability = 1.0
export(float) var shotgun_probability = 1.0


onready var weapon_probs = [
	gun_probability,
	assault_rifle_probability,
	shotgun_probability
]

var _prob_sum: float = 0.0


func can_spawn() -> bool:
	return true


func spawn() -> BaseWeapon:
	var dice_roll = rand_range(0, _prob_sum)
	for i in weapon_probs.size():
		dice_roll -= weapon_probs[i]
		if dice_roll <= 0.0:
			return weapon_scenes[i].instance()
	return weapon_scenes[0].instance()


func _ready() -> void:
	assert(weapon_scenes.size() == weapon_probs.size())
	for prob in weapon_probs:
		_prob_sum += prob

