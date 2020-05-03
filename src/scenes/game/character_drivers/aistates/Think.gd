extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

var strategic_points = []
var target_ent # TODO: Stack parameters
var target_point # TODO: Stack parameters

var enemy_iterator = 0

var mockTimeToDie = 5
var mockTimeToKill = 4

func update(_delta):
	if !player.has_weapon():
		if weapons.empty():
			flee()
		else:		
			var weapons_in_range = []
			for weapon in weapons:
				weapons_in_range.append(weapon.position)
			weapons_in_range.sort_custom(self, "_sort_by_distance")
			target_point = weapons_in_range[0]
			emit_signal("finished", "get_weapon")
		return
		
		
	if enemies.empty():
		flee()
		return
		# TODO: Victory dance!		
	
	# TODO: Consider encounters with multiple enemies
	var ttk = mockTimeToKill
	var ttd = mockTimeToDie
	
	if ttd > ttk:
		target_ent = enemies[enemy_iterator]
		emit_signal("finished", "follow_player")
		emit_signal("finished", "attack")
	else:
		flee()
		
		
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
	
func _filter_by_enemy_presence(element) -> bool:
	var enemies = _get_enemies_around_point(element, 400)
	return enemies.empty()
	
# TODO: Use distance from the calculated path
func _sort_by_distance(a,b):
	return player.global_position.distance_to(a) < player.global_position.distance_to(b)
	
func _sort_strategic_points(sort: String, filter: FuncRef):
	var array = []
	for point in strategic_points:
		if filter.call_func(point):
			array.append(point)
	array.sort_custom(self, sort)
	return array
	
		
	
func flee():
	# TODO: Consider fleeing to a point with _fewer_ enemies, rather than none at all
	var points = _sort_strategic_points("_sort_by_distance", funcref(self, "_filter_by_enemy_presence"))
	
	if points.empty(): # or no path available
		print('Fight to the death!')
	else:	
		target_point = points[0]
	emit_signal("finished", "flee")