extends Navigation2D


var obstacles
var players
var centroids
var hiding_area
var hiding_spots

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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
	
func visibility_rays():
	var space_state = get_parent().get_world_2d().get_direct_space_state()
	hiding_spots = []
	for player in players:
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
					hiding_spots.append({
						"position": spot.position,
						"safe_from": player.name
					})
