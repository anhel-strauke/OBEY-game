extends "res://scripts/state_machine/state.gd"

var goal_avoid_enemies: bool = false

var velocity_vector: Vector2 = Vector2.ZERO
var set_path: FuncRef
var get_path_direction: FuncRef
var player
var enemies = []
var navigation: Navigation2D
var path = []

const _SCAN_COUNTDOWN_UPDATE_COUNT: int = 20
var _scan_countdown = _SCAN_COUNTDOWN_UPDATE_COUNT
var _lastEnemies = []

func _update():
	_scan_countdown -= 1
	if _scan_countdown < 1:
		_scan_countdown = _SCAN_COUNTDOWN_UPDATE_COUNT
		var nearby = _get_enemies_around_point(player.global_position, 400)
		var nearbySize = nearby.size()
		var isSituationBad = (goal_avoid_enemies and nearbySize > 0) or (nearbySize != _lastEnemies.size())
		
		if isSituationBad: # fixme: strict equality check
			emit_signal("stack_invalid", "think")
		_lastEnemies = nearby
		

# fixme: read about simpler solutions	
func _get_enemies_around_point(point: Vector2, radius: int):
	var result = []	
	for enemy in enemies:
		if point.distance_to(enemy.global_position) < radius:
			result.push_back(enemy)
	return result

func _find_path(target_pos: Vector2):
	path = navigation.get_simple_path(player.global_position, target_pos, true)
	
func _assign_path(target_pos: Vector2):
	_find_path(target_pos)
	set_path.call_func(path)
