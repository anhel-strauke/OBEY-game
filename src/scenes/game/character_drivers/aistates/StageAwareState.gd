extends "res://scripts/state_machine/state.gd"

var goal_avoid_enemies: bool = false

var velocity_vector: Vector2 = Vector2.ZERO
var set_path: FuncRef
var get_path_direction: FuncRef
var player
var enemies = []

var enemies_rough_pos = {}
var enemies_pos_repeats = {
	0: 0,
	1: 0,
	2: 0,
	3: 0
}
var camper_indexes = []

var navigation: Navigation2D
var nav_instance
var nav_full_outline
var path = []

const _SCAN_COUNTDOWN_UPDATE_COUNT: int = 30
var _scan_countdown = _SCAN_COUNTDOWN_UPDATE_COUNT
var _lastEnemies = []

func _update():
	_scan_countdown -= 1
	if _scan_countdown < 1:
		_scan_countdown = _SCAN_COUNTDOWN_UPDATE_COUNT
		
		for i in range(0, enemies.size()):
			var enemy = enemies[i]
			var miniposition = enemy.global_position/100 # if the enemy doesn't move across a "minimap", they are a camper or stuck
			var old_pos = null
			if(enemies_rough_pos.has(i)):
				old_pos = enemies_rough_pos[i]
				enemies_rough_pos[i] = Vector2(int(miniposition.x), int(miniposition.y))
				if (old_pos - enemies_rough_pos[i]).length() < 0.000001:
					enemies_pos_repeats[i] += 1
				else:					
					enemies_pos_repeats[i] = 0
			else:
				enemies_rough_pos[i] = Vector2(int(miniposition.x), int(miniposition.y))
			var was_camper = camper_indexes.has(i)
			if(enemies_pos_repeats.has(i) and enemies_pos_repeats[i] > 5):
				if !was_camper:
					camper_indexes.append(i)
					_build_dynamic_nav() 
					
			else:
				var camper_index = camper_indexes.find(i)
				if camper_index != -1:
					camper_indexes.remove(camper_index)
					_build_dynamic_nav()
		
		var nearby = _get_enemies_around_point(player.global_position, 400)
		var nearbySize = nearby.size()
		var isSituationBad = (goal_avoid_enemies and nearbySize > 0) or (nearbySize != _lastEnemies.size())
		
		if isSituationBad: # fixme: strict equality check
			emit_signal("stack_invalid", "think")
		_lastEnemies = nearby
		
		
func _build_dynamic_nav():
	var new_outlines = []
	new_outlines.append(nav_full_outline)
	for camper_index in camper_indexes:
		var camper = enemies[camper_index]
		var new_polygon = []
		new_polygon.append(camper.global_position + Vector2(-80, -80)) # TODO: Calculate proximity from real params
		new_polygon.append(camper.global_position + Vector2(80, -80))
		new_polygon.append(camper.global_position + Vector2(80, 80))
		new_polygon.append(camper.global_position + Vector2(-80, 80))
		var edited_outlines = []
		for sub_poly in new_outlines:
			var chunks = Geometry.clip_polygons_2d(sub_poly, new_polygon)
			for chunk in chunks:
				edited_outlines.append(chunk)
		new_outlines = edited_outlines
		
	var navi_polygon = nav_instance.get_navigation_polygon()
	navi_polygon.clear_polygons()
	navi_polygon.clear_outlines()
	for outline in new_outlines:
		navi_polygon.add_outline(outline)
	navi_polygon.make_polygons_from_outlines()
	nav_instance.enabled = false
	nav_instance.enabled = true

# fixme: read about simpler solutions	
func _get_enemies_around_point(point: Vector2, radius: int):
	var result = []	
	for enemy in enemies:
		if point.distance_to(enemy.global_position) < radius:
			result.push_back(enemy)
	return result

func _find_path(target_pos: Vector2):
	#for camper_index in camper_indexes:
	#var enemy = enemies[camper_index]
	#var new_polygon = []
	#var col_polygon = enemy.get_node("CollisionShape2D").get_polygon()

	#for vector in col_polygon:
	#	new_polygon.append(vector + enemy.get_pos())
	#	var navi_polygon = get_node("NavigationPolygonInstance").get_navigation_polygon()
	#	navi_polygon.add_outline(new_polygon)
	#	navi_polygon.make_polygons_from_outlines()
	
	path = navigation.get_simple_path(player.global_position, target_pos, true)
	
func _assign_path(target_pos: Vector2):
	_find_path(target_pos)
	set_path.call_func(path)
