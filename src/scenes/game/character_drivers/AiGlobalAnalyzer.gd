extends Navigation2D

var obstacles
var players
var centroids
var hiding_area
var hiding_spots

var nav_full_outlines = []

var players_rough_pos = {}
var players_pos_repeats = {
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
}
var camper_indexes = []

const _SCAN_COUNTDOWN_UPDATE_COUNT: int = 5
var _scan_countdown = _SCAN_COUNTDOWN_UPDATE_COUNT

const OBSTACLE_LAYER = 1+32+64
const HIDING_SPOT_LAYER = 128+256

# Called when the node enters the scene tree for the first time.
func _ready():
	obstacles = get_tree().get_nodes_in_group('obstacles')
	players = get_tree().get_nodes_in_group("chars")
	for player in players:
		player.connect("died", self, "_confirm_death")
	centroids = $Centroids.get_children()
	hiding_area = $HidingSpots
	visibility_rays()
	
	var nav_poly = $NavigationPolygonInstance.get_navigation_polygon()
	for i in range(0,nav_poly.get_outline_count()):
		nav_full_outlines.append(nav_poly.get_outline(i))
	
	for cutout in $Cutouts.get_children():	
		var global_polygon = []
		for point in cutout.polygon:
			global_polygon.append(point + cutout.global_position)
		nav_full_outlines = clip_polygons(nav_full_outlines, global_polygon)
	_build_dynamic_nav()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_scan_countdown -= 1
	if _scan_countdown < 1:
		_scan_countdown = _SCAN_COUNTDOWN_UPDATE_COUNT
		#check_for_campers()
		visibility_rays()


func _confirm_death(name):
	var index = -1
	for i in range(0, players.size()):
		if players[i].name == name:
			index = i
	if index == -1:
		print('Illegal operation! Enemy was already confirmed as dead')
		return
	players.remove(index)
	camper_indexes = []
	
# TODO: [PvE]: Disable raychecks for wave enemies	
# TODO: If we've got a hiding spot that is known to hide from multiple enemies, we can skip the check for one of the enemies
func visibility_rays():
	var anyone_has_weapons = false
	for player in players:
		if player.has_weapon():
			anyone_has_weapons = true
			break
	var space_state = get_parent().get_world_2d().get_direct_space_state()
	hiding_spots = []
	for player in players:
		# TODO: Move threat-level logic to the AI itself
		if anyone_has_weapons and !player.has_weapon():
			continue
		for centroid in centroids:
			var results = space_state.intersect_ray(
				player.global_position,
				centroid.global_position, 
				[], OBSTACLE_LAYER )
		
			var outwards = (results.position - centroid.global_position).normalized()*600
			if results:
				#hiding_spots.append(results.position)
				var spot = space_state.intersect_ray(
					centroid.global_position, #+ deep_start,
					centroid.global_position - outwards, 
					[], HIDING_SPOT_LAYER, false, true )
				if spot:
					var full_covered_list = [player.name]
					
					for other_player in players:
						var reverse_check = space_state.intersect_ray(
							spot.position,
							other_player.global_position, 
							[], OBSTACLE_LAYER )
						if reverse_check:
							full_covered_list.append(other_player.name)
					#var path = get_simple_path(player.position, spot.position)
					#var distance = 0
					#var prev_part = null
					#for part in path:
					#	if prev_part != null:
					#		distance += (part - prev_part).length()
					#	prev_part = part
					hiding_spots.append({
						"position": spot.position,
						"safe_from": player.name,
						"full_covered_list": full_covered_list,
					#	"their_walking_distance": distance,
					})

func check_for_campers():
	for i in range(0, players.size()):
		var player = players[i]
		var miniposition = player.global_position/100 # if the enemy doesn't move across a "minimap", they are a camper or stuck
		var old_pos = null
		if(players_rough_pos.has(i)):
			old_pos = players_rough_pos[i]
			players_rough_pos[i] = Vector2(int(miniposition.x), int(miniposition.y))
			if is_zero_approx((old_pos - players_rough_pos[i]).length()):
				players_pos_repeats[i] += 1
			else:					
				players_pos_repeats[i] = 0
		else:
			players_rough_pos[i] = Vector2(int(miniposition.x), int(miniposition.y))
		var was_camper = camper_indexes.has(i)
		if(players_pos_repeats.has(i) and players_pos_repeats[i] > 5):
			if !was_camper:
				camper_indexes.append(i)
				_build_dynamic_nav() 
				
		else:
			var camper_index = camper_indexes.find(i)
			if camper_index != -1:
				camper_indexes.remove(camper_index)
				_build_dynamic_nav()
		
func _build_dynamic_nav():
	var new_outlines = [] + nav_full_outlines
	for camper_index in camper_indexes:
		var camper = players[camper_index]
		var new_polygon = []
		new_polygon.append(camper.global_position + Vector2(-80, -80)) # TODO: Calculate proximity from real params
		new_polygon.append(camper.global_position + Vector2(80, -80))
		new_polygon.append(camper.global_position + Vector2(80, 80))
		new_polygon.append(camper.global_position + Vector2(-80, 80))
		new_outlines = clip_polygons(new_outlines, new_polygon)
		
	var navi_polygon = $NavigationPolygonInstance.get_navigation_polygon()
	navi_polygon.clear_polygons()
	navi_polygon.clear_outlines()
	for outline in new_outlines:
		navi_polygon.add_outline(outline)
	navi_polygon.make_polygons_from_outlines()
	$NavigationPolygonInstance.enabled = false
	$NavigationPolygonInstance.enabled = true

func clip_polygons(outlines, polygon):
	var edited_outlines = []
	for sub_poly in outlines:
		var chunks = Geometry.clip_polygons_2d(sub_poly, polygon)
		for chunk in chunks:
			edited_outlines.append(chunk)
	return edited_outlines
