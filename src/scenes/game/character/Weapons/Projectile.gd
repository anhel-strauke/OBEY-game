extends KinematicBody2D

onready var sound_player = $AudioStreamPlayer

var speed: float = 30.0
var direction_vector: Vector2 = Vector2.ZERO setget set_direction

var friction = 12.0
var _velocity: Vector2 = Vector2.ZERO
var damage = 1
var impulse = 120.0
var gunslinger_name: String
var sound: AudioStream = null

const RippleController = preload("res://scenes/game/effects/RippleController.tscn")

func set_sound(snd: AudioStream) -> void:
	sound = snd


func _ready() -> void:
	sound_player.stream = sound
	remove_child(sound_player)
	get_tree().root.add_child(sound_player)
	sound_player.connect("finished", sound_player, "queue_free")
	sound_player.play()
	

func set_direction(vect: Vector2) -> void:
	direction_vector = vect.normalized()
	_velocity = direction_vector * speed
	
	var controller = RippleController.instance()
	controller.position -= direction_vector * 80.0
	controller.rotation += atan2(direction_vector.y, direction_vector.x)
	add_child(controller)


func _physics_process(delta: float) -> void:
	_velocity = _velocity.move_toward(Vector2.ZERO, friction * delta)
	if _velocity.length() < 10:
		queue_free()
	var collision = move_and_collide(_velocity)
	if collision:
		queue_free()


func _on_HitboxScanner_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent and parent is Character:
		var character = parent as Character
		if gunslinger_name == character.name:
			return # Do not allow suicide
		print(gunslinger_name, " hits ", character.name)
		character.take_damage(damage, gunslinger_name, direction_vector)
		character.set_external_force(direction_vector * impulse)
		queue_free()
