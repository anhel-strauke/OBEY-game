extends "res://scripts/state_machine/state_machine.gd"
class_name AiDriver

export(NodePath) var navigation_path
export(float) var reaction_time = 0
export(float) var courage = 10.05

var navigation
var agent := GSAISteeringAgent.new()
var proximity
var flocking
var acceleration := GSAITargetAcceleration.new()
var pathfollower: GSAIFollowPath = null

var enemies = []
var weapons = []
var enemy_agents = []
var strategic_points = []
func get_velocity_vector() -> Vector2:
	if !consumed_last and states_stack.size() > 1:
		return states_stack[1].velocity_vector
	else:
		return current_state.velocity_vector

func is_fire_pressed() -> bool:
	return current_state._is_fire_pressed()

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
	
	var world_width = 1920 # TODO: Stabilize API
	var world_height = 1080
	
	# fixme: Unused, rework as mid-way points between bonuses for $HoldPosition
	strategic_points.push_back(Vector2(world_width/4, world_height/4))
	strategic_points.push_back(Vector2(world_width*3/4, world_height/4))
	strategic_points.push_back(Vector2(world_width/4, world_height*3/4))
	strategic_points.push_back(Vector2(world_width*3/4, world_height*3/4))
		
	$Think.strategic_points = strategic_points
	
func _on_all_players_ready():
	navigation = get_node(navigation_path)
	var characters = get_tree().get_nodes_in_group("chars")
	for character in characters:
		if character != get_parent():
			enemies.append(character)
	for enemy in enemies:
		var enemy_agent = GSAISteeringAgent.new()
		enemy_agent.linear_acceleration_max = get_parent().ACCELERATION
		enemy_agent.linear_speed_max = get_parent().MAX_SPEED
		enemy_agent.bounding_radius = 100
		enemy_agents.append(enemy_agent)
		enemy.connect("died", self, "_confirm_death")
		
	var weapon_spawners = get_tree().get_nodes_in_group("weapon_spawners")
	for spawner in weapon_spawners:
		spawner.connect("spawned", self, "_on_weapon_spawn")
		spawner.connect("picked_up", self, "_on_weapon_pick_up")
	
	#proximity.agents = enemy_agents
	proximity = GSAIRadiusProximity.new(agent, enemy_agents, 75) # TODO: Calculate proximity from real params
	flocking = GSAIAvoidCollisions.new(agent, proximity)
	
	var set_path = funcref(self, "_set_path")
	var get_path_direction = funcref(self, "_path_direction")
	var nav_instance = navigation.get_node("NavigationPolygonInstance")
	for child in get_children():
		child.navigation = navigation # fixme: AiDriver-wide nav polygons
		child.nav_instance = nav_instance
		child.player = get_parent()
		child.enemies = enemies
		child.set_path = set_path
		child.get_path_direction = get_path_direction
		child.courage = courage
		child.reaction_time = reaction_time
	
	agent.linear_acceleration_max = get_parent().ACCELERATION
	agent.linear_speed_max = get_parent().MAX_SPEED
	agent.bounding_radius = 100
	
func _change_state(state_name):
	if not _active:
		return
	if state_name in ["follow_player", "attack", "flee", "hold_position", "get_weapon"]:
		states_stack.push_front(states_map[state_name])
	if state_name == "follow_player": # and current_state == $Flee:
		$FollowPlayer.initialize($Think.target_ent)
	if state_name == "attack": # and current_state == $Flee:
		$Attack.initialize($Think.target_ent)
	if state_name == "flee":
		$Flee.initialize($Think.target_point)
	if state_name == "hold_position":
		$HoldPosition.initialize(get_parent().position)
	if state_name == "get_weapon":
		$GetWeapon.initialize($Think.target_point)
	._change_state(state_name)

# fixme: This will fail on an unconsumed Think
func get_path():
	if !consumed_last and states_stack.size() > 1:
		return states_stack[1].path
	else:
		return current_state.path
		
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
		pathfollower.is_arrive_enabled = false	
		pathfollower.path_offset = 75.0
	else:
		pathfollower.path = aiPath
	
func _path_direction(avoid: bool = false):
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
		#var space_state = get_parent().get_world_2d().get_direct_space_state()
		#var result = space_state.intersect_ray(get_parent().global_position,get_parent().global_position + course * 450 ,[get_parent()] )
		#if result.size(): # Replace raycast with a course_correction/course angle check and move the bot perpendicular to the course to try "walking around"
		#	return course_correction
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
	#if get_parent().name == 'Mason':
	#	get_parent()._suicide()

func _confirm_death(name):
	var index = -1
	for i in range(0, enemies.size()):
		if enemies[i].name == name:
			index = i
	if index == -1:
		print('Illegal operation! Enemy was already confirmed as dead')
		return
	enemies.remove(index)
	enemy_agents.remove(index)
	for child in get_children():
		child.enemies = enemies
	proximity.agents = enemy_agents
	._reset_to_state("think")
	
func _on_weapon_spawn(name, weapon_position):
	var weapon_info = { # fixme: Consider passing Weapon object instead of assembling dictionaries
		"name": name,
		"position": weapon_position
	}
	weapons.append(weapon_info)
	for child in get_children():
		child.weapons = weapons
	._reset_to_state("think")
	
func _on_weapon_pick_up(name):
	var index = -1
	for i in range(0, weapons.size()):
		if weapons[i].name == name:
			index = i
	if index == -1:
		print('Illegal operation! No such weapon!')
		return
	weapons.remove(index)
	for child in get_children():
		child.weapons = weapons
	if get_parent().has_weapon():
		get_parent().weapon_obj.connect("out_of_ammo", self, "_on_out_of_ammo")
	._reset_to_state("think")

func _on_out_of_ammo():
	if !get_parent().has_weapon():
		._reset_to_state("think")
