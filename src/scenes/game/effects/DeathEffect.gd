extends KinematicBody2D


onready var sprite_root = $Sprite

var _direction: Vector2 = Vector2.ZERO
const FRICTION = 8600.0
var _velocity: Vector2


func set_sprite(sprite: Node2D) -> void:
	var parent = sprite.get_parent()
	if parent:
		parent.remove_child(sprite)
	sprite_root.add_child(sprite)
	sprite.position = Vector2.ZERO


func set_direction(dir: Vector2) -> void:
	_direction = dir.normalized()
	_velocity = _direction * 3000
	

func _physics_process(delta: float) -> void:
	_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	_velocity = move_and_slide(_velocity)
