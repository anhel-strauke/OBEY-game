extends "res://scripts/state_machine/state_machine.gd"
class_name AiDriver

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
	# TODO: Automatic resolution of objects
	enemies.push_back(get_parent().get_parent().get_node("Character"))
	enemies.push_back(get_parent().get_parent().get_node("Character2"))
	
	for child in get_children():
		child.player = get_parent()
		child.enemies = enemies
	
	var world_width = 1920 # TODO: Stabilize API
	var world_height = 1080
	strategic_points.push_back(Vector2(world_width/4, world_height/4))
	strategic_points.push_back(Vector2(world_width*3/4, world_height/4))
	strategic_points.push_back(Vector2(world_width/4, world_height*3/4))
	strategic_points.push_back(Vector2(world_width*3/4, world_height*3/4))
		
	$Think.strategic_points = strategic_points
	# TODO: Remove "safe zone" :) 
	$FollowPlayer.safe_zone = enemies[0].position
	
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
