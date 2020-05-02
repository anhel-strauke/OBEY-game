extends "res://scripts/state_machine/state.gd"

var player
var enemies = []
var strategic_points = []
var target_ent # TODO: Stack parameters
var target_point # TODO: Stack parameters

var enemy_iterator = 0

var mockTimeToDie = 5
var mockTimeToKill = 4

func update(_delta):
	# TODO: Consider encounters with multiple enemies
	var ttk = mockTimeToKill
	var ttd = mockTimeToDie
	
	if ttd > ttk:
		target_ent = enemies[enemy_iterator]
		emit_signal("finished", "attack")
	else:
		# TODO: Consider fleeing to a point with _fewer_ enemies, rather than none at all
		var points = _sort_strategic_points("_sort_by_distance", funcref(self, "_filter_by_enemy_presence"))
		print(points)
		target_point = points[0]
		emit_signal("finished", "flee")
		
		
	#enemy_iterator += 1
	#if enemy_iterator == enemies.size():
	#	enemy_iterator = 0	
	#emit_signal("finished", "follow_player")
	
	
func incMockTTK():
	mockTimeToKill += 1
	
func decMockTTK():
	mockTimeToKill -= 1

func get_state_description():
	return "Think"
	
# fixme: read about simpler solutions	
func _get_enemies_around_point(point: Vector2, radius: int):
	var result = []	
	for enemy in enemies:
		if point.distance_to(enemy.global_position) < radius:
			result.push_back(enemy)
	return result
	
func _filter_by_enemy_presence(element) -> bool:
	var enemies = _get_enemies_around_point(element, 400)
	return enemies.empty()
	
func _sort_by_distance(a,b):
	return player.global_position.distance_to(a) < player.global_position.distance_to(b)
	
func _sort_strategic_points(sort: String, filter: FuncRef):
	var array = []
	for point in strategic_points:
		if filter.call_func(point):
			array.append(point)
	array.sort_custom(self, sort)
	return array
	
		
	
