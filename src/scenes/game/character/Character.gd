extends KinematicBody2D
class_name Character

enum State {
	Invalid,
	Idle,
	Run,
	Died
}

signal died(name)
signal health_changed(new_health)
signal ammo_changed(new_ammo)

const WeaponDropEffect = preload("res://scenes/game/effects/WeaponDropEffect.tscn")
const DeathEffect = preload("res://scenes/game/effects/DeathEffect.tscn")

export(String) var display_name
export(int, "Reptiloid", "Mason", "Grayman", "5G Tower") var icon_index = 0
export var MAX_SPEED: float = 800.0
export var ACCELERATION: float = 2400.0
export var FRICTION: float = 2200.0

export var max_hitpoints: float = 10.0

onready var driver = $Driver
onready var sprite = $Sprite/Sprite
onready var weapon_pivot = $Sprite/Sprite/WeaponPivot

var _velocity: Vector2 = Vector2.ZERO
var _attack_direction: Vector2 = Vector2.LEFT
var _input_vector: Vector2 = Vector2.ZERO
onready var _hp: float = max_hitpoints
var external_force: Vector2 = Vector2.ZERO
var state: int = State.Idle setget set_state
var weapon_obj = null
var immortal: bool = false

var fire_was_pressed: bool = false


func has_weapon() -> bool:
	return weapon_obj != null


func set_look_right(right: bool) -> void:
	if right:
		sprite.scale = Vector2(-1.0, 1.0)
		_attack_direction = Vector2.RIGHT
	else:
		sprite.scale = Vector2(1.0, 1.0)
		_attack_direction = Vector2.LEFT


func _process(delta: float) -> void:
	#process_light()
	if not Global.game_is_on:
		return
	if not driver:
		return
	_input_vector = driver.get_velocity_vector()
	if driver.is_fire_pressed():
		if weapon_obj:
			if weapon_obj.can_attack(fire_was_pressed):
				weapon_obj.do_fire(_attack_direction)
		fire_was_pressed = true
	else:
		fire_was_pressed = false


func _physics_process(delta: float) -> void:
	var total_vector = _input_vector + external_force
	if total_vector != Vector2.ZERO:
		_velocity = _velocity.move_toward(total_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if _input_vector != Vector2.ZERO:
		_attack_direction = _input_vector.normalized()

	_velocity = move_and_slide(_velocity)

	if _velocity.length() < 0.05:
		_velocity = Vector2.ZERO

	if _input_vector != Vector2.ZERO:
		for i in get_slide_count():
			var collision := get_slide_collision(i)
			if collision.collider.has_method("set_external_force"):
				var other_character = collision.collider
				var direction = -1.0 * collision.normal
				var force_amount = max(_velocity.length(), MAX_SPEED * 0.1)
				var push_force = direction * force_amount * 0.2
				other_character.set_external_force(push_force)

	if _input_vector.x < -0.1:
		sprite.scale = Vector2(1.0, 1.0)
	elif _input_vector.x > 0.1:
		sprite.scale = Vector2(-1.0, 1.0)


	if weapon_obj:
		var dir_vector = Vector2.LEFT
		var angle_rad = 0.0
		if sprite.scale.x < 0:
			dir_vector = Vector2.RIGHT
			angle_rad = _attack_direction.angle_to(dir_vector)
		else:
			angle_rad = dir_vector.angle_to(_attack_direction)
		weapon_obj.transform = Transform2D(angle_rad, Vector2.ZERO)

	if is_zero_approx(_velocity.length()) and is_zero_approx(_input_vector.length()):
		self.state = State.Idle
	else:
		self.state = State.Run

	external_force = external_force.move_toward(Vector2.ZERO, FRICTION * delta)


func set_state(st: int) -> void:
	if state != st:
		state = st
		play_state_animation(st)


func set_external_force(force: Vector2) -> void:
	external_force = force


func take_damage(dmg: float, from: String, direction: Vector2) -> void:
	if immortal:
		return
	_hp -= dmg
	emit_signal("health_changed", _hp)
	if _hp <= 0.0:
		print(name, " dies")
		set_state(State.Idle)
		drop_weapon()
		var death = DeathEffect.instance()
		Global.find_bullet_parent().add_child(death)
		death.global_position = global_position
		death.scale = sprite.scale
		death.set_sprite(sprite)
		death.set_direction(direction)
		#sprite.scale = Vector2(1.0, 1.0)
		emit_signal("died", name)
		queue_free()


func set_weapon_object(weapon: BaseWeapon) -> void:
	if weapon_pivot:
		if weapon_obj:
			drop_weapon()
		weapon_obj = weapon
		weapon.get_parent().remove_child(weapon)
		weapon.signal_picked_up()
		weapon_pivot.add_child(weapon)
		weapon.position = Vector2.ZERO
		weapon.transform = Transform2D(0.0, Vector2.ZERO)
		weapon_obj.connect("out_of_ammo", self, "drop_weapon")
		weapon_obj.connect("ammo_changed", self, "update_ammo")
		weapon_obj.owner_name = name
		if weapon_obj.is_firearm:
			emit_signal("ammo_changed", weapon_obj.ammo)
		else:
			emit_signal("ammo_changed", 0)


func update_ammo(ammo: int):
	emit_signal("ammo_changed", ammo)


func drop_weapon() -> void:
	if weapon_obj:
		var effect_parent = Global.find_bullet_parent()
		if effect_parent:
			var drop_effect = WeaponDropEffect.instance()
			effect_parent.add_child(drop_effect)
			drop_effect.set_weapon(weapon_obj)
			drop_effect.scale = sprite.scale
			drop_effect.global_position = global_position
		weapon_obj = null
		emit_signal("ammo_changed", 0)


func play_state_animation(state: int) -> void:
	pass


func _on_WeaponPickup_area_entered(area: Area2D) -> void:
	print("Collision with ", area.name)
	var weapon_candidate = area.get_parent()
	if weapon_candidate and weapon_candidate != weapon_obj:
		if weapon_candidate is BaseWeapon:
			area.set_deferred("monitorable", false)
			set_weapon_object(weapon_candidate)


func become_immortal() -> void:
	immortal = true
