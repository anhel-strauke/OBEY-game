extends KinematicBody2D


var speed: float = 30.0
var direction_vector: Vector2 = Vector2.ZERO setget set_direction

const FRICTION = 12.0
var _velocity: Vector2 = Vector2.ZERO
var gunslinger_name: String


func set_direction(vect: Vector2) -> void:
	direction_vector = vect.normalized()
	_velocity = direction_vector * speed

func _physics_process(delta: float) -> void:
	_velocity = _velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	var collision = move_and_collide(_velocity)
	if collision:
		print(collision.collider.name)
		queue_free()


func _on_HitboxScanner_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent is Character:
		var character = parent as Character
		print(gunslinger_name, " hits ", character.name)
		queue_free()
