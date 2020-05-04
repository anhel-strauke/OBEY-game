extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

var strategic_points = []
var target_ent # TODO: Stack parameters
var target_point # TODO: Stack parameters

var mockTimeToDie = 5
var mockTimeToKill = 4


func update(_delta):
	
	# TODO: Move to the computed decision graph
	if !player.has_weapon():
		if !weapons.empty():
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
		
	#var stack_item = {
	#	"action": "",
	#	"param": "",
	#	"our_dps": "",
	#	"our_hp": "",
	#	"their_dps": "",
	#	"their_hp": "",
	#	"distance": "",
	#}
	var best_item = {
		"score": -9999, # undefined, but all possible values are more than -9999
		"action": "",
		"param": "",
		"_enemy": null
	}	
	
	var enemy_estimations = []
	for enemy in enemies:
		var distance = player.global_position.distance_to(enemy.global_position)
		var their_dps = 1
		if enemy.has_weapon():
			their_dps += estimate_dps(enemy.weapon_obj.name, distance)
		enemy_estimations.append({
			"enemy": enemy,
			"distance": distance,
			"their_dps": their_dps,
		})
	# TODO: Calculate full paths
	var our_hp = player._hp
	for est in enemy_estimations:
		var enemy = est.enemy
		var their_hp = enemy._hp
		var their_dps = 1
		for another_enemy in enemy_estimations:
			their_dps += est.their_dps
		var our_dps = 1
		if player.has_weapon():
			our_dps = estimate_dps(player.weapon_obj.name, est.distance)
		
		var new_score = recursive_reasoning("follow_player", enemy.name, 
			our_dps, our_hp, their_dps, their_hp, est.distance)
		
		if best_item.score < new_score:
			best_item.score = new_score
			best_item.action = "follow_player"
			best_item.param = enemy.name
			best_item._enemy = enemy
			
			
	if best_item.score >= (0 - courage):
		#print(best_item.score)
		target_ent = best_item._enemy
		if player.has_weapon():
			emit_signal("finished", "follow_player")
			emit_signal("finished", "attack")
		else:
			target_ent = best_item._enemy
			flee()	
			emit_signal("finished", "attack")
	else:
		flee()
		#weapons
	#enemy_iterator += 1
	#if enemy_iterator == enemies.size():
	#	enemy_iterator = 0	
	#emit_signal("finished", "follow_player")
	return true
	

# TODO: Consider encounters with multiple enemies
# TODO: Estimate damage received en route
# TODO: Take obstacles into account when calculating mean DPS
# TODO: Compute paths globally to operate with distances efficiently
# TODO: Get character speed data
# Keep in mind that we only need to get NEXT action as a result, because situations might change and stack will get invalid
# Method returns best score only
# TODO: Depth of more than 2 
func recursive_reasoning(action, param, our_dps, our_hp, their_dps, their_hp, distance, distanceB = 0):
	var mean_speed = 1000
	var our_prct_lost = (their_dps*distance/mean_speed)/our_hp
	if action == "get_weapon":	
		our_dps = estimate_dps(param, distanceB)
		return our_prct_lost + recursive_reasoning("follow_player", null, our_dps, our_hp, their_dps, their_hp, distanceB)
	if action == "follow_player":
		var their_prct_lost = (our_dps*distance/mean_speed)/their_hp
		return their_prct_lost - our_prct_lost
	#if action == "hold_position":
	#if action == "get_bonus":
	
func estimate_dps(weapon_name, distance):
	var mock_mean_dps = 25
	
	var distance_multiplier = 1
	if distance < 650:
		distance_multiplier = 2
	if distance < 400 and weapon_name == "Shotgun":
		distance_multiplier = 3
	
	return mock_mean_dps * distance_multiplier
	
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
		target_point = player.global_position
		emit_signal("finished", "hold_position")
	else:	
		var spot = spots[0]
		#if spot.full_covered_list.size() < enemies.size():
			#print('Fight to the death!')
		#	emit_signal("finished", "hold_position")
		target_point = spot.position
		emit_signal("finished", "flee")
