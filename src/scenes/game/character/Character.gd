extends KinematicBody2D


export var MAX_SPEED: float = 1100.0
export var ACCELERATION: float = 2400.0
export var FRICTION: float = 1800.0

onready var driver = $Driver

var _velocity: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if not driver:
		return
	var input_vector = driver.get_velocity_vector()
	if input_vector != Vector2.ZERO:
		_velocity = _velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_velocity = move_and_slide(_velocity)
	
