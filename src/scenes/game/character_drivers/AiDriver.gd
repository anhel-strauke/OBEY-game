extends "res://scripts/state_machine/state_machine.gd"
class_name AiDriver

export(NodePath) var navigation_path
var navigation
var agent := GSAISteeringAgent.new()
var proximity
var flocking
var acceleration := GSAITargetAcceleration.new()
var pathfollower: GSAIFollowPath = null

var enemies = []
var enemy_agents = []
var strategic_points = []
func get_velocity_vector() -> Vector2:
	return current_state.velocity_vector

func is_fire_pressed() -> bool:
	return false


func is_ability_pressed() -> bool:
	return false
	
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
	enemies.push_back(get_parent().get_parent().get_node("Reptiloid"))
	enemies.push_back(get_parent().get_parent().get_node("Tower5G"))
	for enemy in enemies:
		var enemy_agent = GSAISteeringAgent.new()
		enemy_agent.linear_acceleration_max = get_parent().ACCELERATION
		enemy_agent.linear_speed_max = get_parent().MAX_SPEED
		enemy_agent.bounding_radius = 100
		enemy_agents.append(enemy_agent)
	#proximity.agents = enemy_agents
	proximity = GSAIRadiusProximity.new(agent, enemy_agents, 75) # TODO: Calculate proximity from real params
	flocking = GSAIAvoidCollisions.new(agent, proximity)
	
	var set_path = funcref(self, "_set_path")
	var get_path_direction = funcref(self, "_path_direction")
	for child in get_children():
		child.navigation = navigation # fixme: AiDriver-wide nav polygons
		child.nav_instance = navigation.get_node("NavigationPolygonInstance")
		child.nav_full_outline = child.nav_instance.get_navigation_polygon().get_outline(0)
		child.player = get_parent()
		child.enemies = enemies
		child.set_path = set_path
		child.get_path_direction = get_path_direction
	
	agent.linear_acceleration_max = get_parent().ACCELERATION
	agent.linear_speed_max = get_parent().MAX_SPEED
	agent.bounding_radius = 100
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
	if path == null or path.empty():
		return # this is a valid case (if navpolygon is so closed up, the bot can't flee)
	var vec3Points = []
	for line in path:
		vec3Points.append(GSAIUtils.to_vector3(line))
	var aiPath = GSAIPath.new(vec3Points)
	if pathfollower == null:
		pathfollower = GSAIFollowPath.new(agent, aiPath)		
		pathfollower.path_offset = 150.0
	else:
		pathfollower.path = aiPath
	
func _path_direction(avoid: bool = true):
	var course_correction = null
	
	if avoid:
		flocking.calculate_steering(acceleration) 
		var length = acceleration.linear.length()
		if length != 0:
			course_correction = GSAIUtils.to_vector2(acceleration.linear / get_parent().ACCELERATION)
		
	if pathfollower == null:
		if course_correction == null:
			return Vector2.ZERO		
		else:
			return course_correction
	pathfollower.calculate_steering(acceleration)
	var course = GSAIUtils.to_vector2(acceleration.linear / get_parent().ACCELERATION)
	if course_correction == null:
		return course
	else:
		var space_state = get_parent().get_world_2d().get_direct_space_state()
		var result = space_state.intersect_ray(get_parent().global_position,get_parent().global_position + course * 450 ,[get_parent()] )
		if result.size(): # Replace raycast with a course_correction/course angle check and move the bot perpendicular to the course to try "walking around"
			return course_correction
		var percentage = get_parent()._velocity.length() / get_parent().MAX_SPEED
		return (course * percentage + course_correction) / (1 + percentage)

	
func _update_agent(agent, character) -> void:
	agent.position.x = character.global_position.x
	agent.position.y = character.global_position.y
	agent.orientation = 0
	agent.linear_velocity.x = character._velocity.x
	agent.linear_velocity.y = character._velocity.y
	agent.angular_velocity = 0	
	
func _process(delta):
	_update_agent(agent, get_parent())
	for i in range(0, enemies.size()):
		_update_agent(enemy_agents[i], enemies[i])
	._process(delta)	
