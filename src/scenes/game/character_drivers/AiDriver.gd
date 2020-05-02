extends "res://scripts/state_machine/state_machine.gd"
class_name AiDriver

export(NodePath) var navigation_path
var navigation
onready var agent := GSAISteeringAgent.new()
var acceleration := GSAITargetAcceleration.new()
var pathfollower: GSAIFollowPath = null

var enemies = []
var strategic_points = []
func get_velocity_vector() -> Vector2:
	return current_state.velocity_vector
	
func _ready():
	states_map = {
		"think": $Think,
		"get_weapon": $GetWeapon,
		"get_bonus": $GetBonus,
		"follow_player": $FollowPlayer,
		"attack": $Attack,
		"flee": $Flee,
		"hold_position": $HoldPosition
	}
	navigation = get_node(navigation_path)
	# TODO: Automatic resolution of objects
	enemies.push_back(get_parent().get_parent().get_node("Character"))
	enemies.push_back(get_parent().get_parent().get_node("Character2"))
	var set_path = funcref(self, "_set_path")
	var get_path_direction = funcref(self, "_path_direction")
	for child in get_children():
		child.navigation = navigation
		child.player = get_parent()
		child.enemies = enemies
		child.set_path = set_path
		child.get_path_direction = get_path_direction
	
	agent.linear_acceleration_max = get_parent().ACCELERATION
	agent.linear_speed_max = get_parent().MAX_SPEED
	var world_width = 1920 # TODO: Stabilize API
	var world_height = 1080
	strategic_points.push_back(Vector2(world_width/4, world_height/4))
	strategic_points.push_back(Vector2(world_width*3/4, world_height/4))
	strategic_points.push_back(Vector2(world_width/4, world_height*3/4))
	strategic_points.push_back(Vector2(world_width*3/4, world_height*3/4))
		
	$Think.strategic_points = strategic_points
	
func _change_state(state_name):
	if not _active:
		return
	if state_name in ["follow_player", "attack", "flee", "hold_position"]:
		states_stack.push_front(states_map[state_name])
	if state_name == "follow_player": # and current_state == $Flee:
		$FollowPlayer.initialize($Think.target_ent)
	if state_name == "attack": # and current_state == $Flee:
		$Attack.initialize($Think.target_ent)
	if state_name == "flee":
		$Flee.initialize($Think.target_point)
	if state_name == "hold_position":
		$HoldPosition.initialize(get_parent().position)
	._change_state(state_name)

# Abrupt changes of the game field should trigger recalculation of the action stack
# Examples:
# - Random bonus/weapon spawn
# - New player in combat radius
func incMockTTK():
	$Think.incMockTTK()
	._reset_to_state("think")
	
func decMockTTK():
	$Think.decMockTTK()
	._reset_to_state("think")

func _set_path(path: Array):
	var vec3Points = []
	for line in path:
		vec3Points.append(GSAIUtils.to_vector3(line))
	var aiPath = GSAIPath.new(vec3Points)
	if pathfollower == null:
		pathfollower = GSAIFollowPath.new(agent, aiPath)		
		pathfollower.path_offset = 150.0
	else:
		pathfollower.path = aiPath
	
func _path_direction():
	if pathfollower == null:
		return Vector2.ZERO		
	pathfollower.calculate_steering(acceleration)
	print(acceleration.linear)
	return GSAIUtils.to_vector2(acceleration.linear / get_parent().ACCELERATION)

	
func _update_agent() -> void:
	agent.position.x = get_parent().global_position.x
	agent.position.y = get_parent().global_position.y
	agent.orientation = 0
	agent.linear_velocity.x = get_parent()._velocity.x
	agent.linear_velocity.y = get_parent()._velocity.y
	agent.angular_velocity = 0	
	
func _process(delta):
	_update_agent()
	._process(delta)	
