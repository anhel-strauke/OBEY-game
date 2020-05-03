extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

var strategic_points = []
var target_ent # TODO: Stack parameters
var target_point # TODO: Stack parameters

var enemy_iterator = 0

var mockTimeToDie = 5
var mockTimeToKill = 4

func update(_delta):
	flee()
	return
	
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
	
func _filter_by_enemy_safety(element) -> bool:
	return element.safe_from != player.name
	
# TODO: Use distance from the calculated path
func _sort_by_distance(a,b):
	return player.global_position.distance_to(a) < player.global_position.distance_to(b)
	
func _sort_spots_by_distance(a,b):
	return player.global_position.distance_to(a.position) < player.global_position.distance_to(b.position)

func _sort_spots_by_distance_and_threats(a,b):
	# fixme: Check if these threats matter to the player
	if a.full_covered_list.size() != b.full_covered_list.size():
		return a.full_covered_list.size() > b.full_covered_list.size()
	
	return player.global_position.distance_to(a.position) < player.global_position.distance_to(b.position)
#func _sort_spots_by_distance_diff(a,b):
#	return a.their_walking_distance - player.global_position.distance_to(a.position) > b.their_walking_distance	 - player.global_position.distance_to(b.position)
	
func _sort(els: Array, sort: String, filter: FuncRef):
	var array = []
	for el in els:
		if filter.call_func(el):
			array.append(el)
	array.sort_custom(self, sort)
	return array
	
	
func flee():
	# TODO: Consider fleeing to a point with _fewer_ enemies, rather than none at all
	#var points = _sort(strategic_points, "_sort_by_distance", funcref(self, "_filter_by_enemy_presence"))
	var spots = _sort(navigation.hiding_spots, "_sort_spots_by_distance_and_threats", funcref(self, "_filter_by_enemy_safety"))
	
	
	if spots.empty(): # or no path available
		#print('Fight to the death!')
		target_point = player.global_position
		emit_signal("finished", "hold_position")
	else:	
		var spot = spots[0]
		if spot.full_covered_list.size() < enemies.size():
			#print('Fight to the death!')
			emit_signal("finished", "hold_position")
		target_point = spot.position
		emit_signal("finished", "flee")
