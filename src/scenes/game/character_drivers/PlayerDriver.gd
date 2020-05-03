extends Node
class_name PlayerDriver

export(int) var player_index: int = -1

onready var agent := GSAISteeringAgent.new()

func get_velocity_vector() -> Vector2:
	if player_index >= 0:
		return GameInput.player(player_index).direction()
	return Vector2.ZERO

func is_fire_pressed() -> bool:
	if player_index >= 0:
		return GameInput.player(player_index).is_pressed(Constants.Actions.Fire)
	return false


func is_ability_pressed() -> bool:
	if player_index >= 0:
		return GameInput.player(player_index).is_pressed(Constants.Actions.AddFire)
	return false

func _ready():
	agent.linear_acceleration_max = get_parent().ACCELERATION
	agent.linear_speed_max = get_parent().MAX_SPEED
	agent.bounding_radius = 100

func _process(delta):
	_update_agent()

func _update_agent() -> void:
	agent.position.x = get_parent().global_position.x
	agent.position.y = get_parent().global_position.y
	agent.orientation = 0
	agent.linear_velocity.x = get_parent()._velocity.x
	agent.linear_velocity.y = get_parent()._velocity.y
	agent.angular_velocity = 0
