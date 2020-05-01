extends "res://scripts/state_machine/state_machine.gd"
class_name AiDriver

var enemies = []
func get_velocity_vector() -> Vector2:
	return current_state.velocity_vector
	
	
func _ready():
	states_map = {
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
	$Think.enemies = enemies
	# TODO: Remove "safe zone" :) 
	$FollowPlayer.safe_zone = enemies[0].position
	$HoldPosition.initialize(get_parent(), get_parent().position)
	
func _change_state(state_name):
	if not _active:
		return
	if state_name in ["follow_player", "flee", "hold_position"]:
		states_stack.push_front(states_map[state_name])
	if state_name == "follow_player": # and current_state == $Flee:
		$FollowPlayer.initialize(get_parent(), $Think.target)
	._change_state(state_name)
