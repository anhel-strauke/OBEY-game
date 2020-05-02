extends KinematicBody2D
class_name Character

enum State {
	Idle,
	Run
}


export var MAX_SPEED: float = 800.0
export var ACCELERATION: float = 2400.0
export var FRICTION: float = 2200.0

onready var driver = $Driver
onready var sprite = $Sprite

var _velocity: Vector2 = Vector2.ZERO
var _attack_direction: Vector2 = Vector2.LEFT
var _input_vector: Vector2 = Vector2.ZERO
export var external_force: Vector2 = Vector2.ZERO
var state: int = State.Idle setget set_state


func _process(delta: float) -> void:
	if not driver:
		return
	_input_vector = driver.get_velocity_vector()


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
	
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		if collision.collider.has_method("set_external_force"):
			var other_character = collision.collider
			var direction = -1.0 * collision.normal
			var force_amount = max(_velocity.length(), MAX_SPEED * 0.1)
			var push_force = direction * force_amount * 0.4
			other_character.set_external_force(push_force)
		
	if not is_zero_approx(_input_vector.x) and _input_vector.x < 0.0:
		sprite.scale = Vector2(1.0, 1.0)
	elif not is_zero_approx(_input_vector.x) and  _input_vector.x > 0.0:
		sprite.scale = Vector2(-1.0, 1.0)

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


func play_state_animation(state: int) -> void:
	pass
