extends KinematicBody2D


enum State {
	Idle,
	Run
}


export var MAX_SPEED: float = 800.0
export var ACCELERATION: float = 2400.0
export var FRICTION: float = 1800.0

onready var driver = $Driver
onready var sprite = $Sprite

var _velocity: Vector2 = Vector2.ZERO
var _attack_direction: Vector2 = Vector2.LEFT
var state: int = State.Idle setget set_state


func _process(delta: float) -> void:
	if not driver:
		return
	var input_vector = driver.get_velocity_vector()
	if input_vector != Vector2.ZERO:
		_velocity = _velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		_attack_direction = input_vector
	else:
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_velocity = move_and_slide(_velocity)
	if _velocity.length() < 0.05:
		_velocity = Vector2.ZERO
	if not is_zero_approx(input_vector.x) and input_vector.x < 0.0:
		sprite.scale = Vector2(1.0, 1.0)
	elif not is_zero_approx(input_vector.x) and  input_vector.x > 0.0:
		sprite.scale = Vector2(-1.0, 1.0)
	elif not is_zero_approx(_velocity.x) and _velocity.x < 0.0:
		sprite.scale = Vector2(1.0, 1.0)
	elif not is_zero_approx(_velocity.x) and _velocity.x > 0.0:
		sprite.scale = Vector2(-1.0, 1.0)

	if is_zero_approx(_velocity.length()) and is_zero_approx(input_vector.length()):
		self.state = State.Idle
	else:
		self.state = State.Run

func set_state(st: int) -> void:
	if state != st:
		state = st
		play_state_animation(st)


func play_state_animation(state: int) -> void:
	pass
