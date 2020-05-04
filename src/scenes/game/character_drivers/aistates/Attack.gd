extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"


const WEAPON_COOLDOWN: int = 5
var countdown = -1
var target

var reaction_countdown: float

func initialize(newTarget):
	target = newTarget
	reaction_countdown = reaction_time

func update(delta):
	._update()
	
	if reaction_countdown > 0:
		reaction_countdown -= delta
		return false
	
	# var aim_direction = player.position.direction_to(target.position)
	#get_simple_path(start_position, end_position, true)
	var aim_direction = predict_without_acceleration()
	
	var weapon = player.weapon_obj
	# fixme: Stabilize API
	var shooting_range = 900
	if weapon.name == "Shotgun":
		#print('Detected shotgun')
		shooting_range = 500
	
	var space_state = player.get_parent().get_world_2d().get_direct_space_state()
	# TODO: ignore pits
	var bullet_origin = player.global_position
	#if player.has_weapon():
	#	bullet_origin = player.weapon_obj.bullet_spawn.global_position
	var results = space_state.intersect_ray(bullet_origin, bullet_origin + aim_direction * shooting_range ,[player] )
	var should_shoot = false
	if results:
		if results.collider == target:
			should_shoot = true
			velocity_vector = aim_direction
			if countdown > -1:
				countdown -= 1
		else:
			reaction_countdown = reaction_time				
			
	# / 10000 # fixme: stop on "shoot" to visualize cooldown
	# var distance = player.position.distance_to(target.position)
	return should_shoot
	
func _is_fire_pressed() -> bool:
	if countdown == -1:
		countdown = WEAPON_COOLDOWN + int(reaction_time*4)
		return true
	return false
# To make it more accurate, we can do:
# 1. Add acceleration to the equation
# 2. Consider _changing_ acceleration
# 3. Record patterns of acceleration changes to predict target's dodging
func predict_without_acceleration():
	var bullet_origin = player.global_position
	var bullet_speed = 10000 # TODO: Get current gun stats
	var target_origin = target.global_position
	var target_velocity = target._velocity # fixme: Stabilize API
	# ===================	
	var Sb = bullet_speed
	var Sbsqr = pow(Sb,2)
	var St = target_velocity.length()
	var Stsqr = target_velocity.length_squared()
	var Vt = target_velocity
	var Dvec = target_origin - bullet_origin
	var D = Dvec.length()
	var Dsqr = Dvec.length_squared()
	
	# Theta is the angle of shooting direction we are looking for
	var cosTheta = (-Dvec).normalized().dot(Vt.normalized())
	
	var a = Sbsqr - Stsqr
	var b = -2*D*St*cosTheta
	
	var x = sqrt( pow(b, 2) + 4*a*Dsqr )
	
	var time_of_impact1 = (b + x) / (2*a)
	var time_of_impact2 = (b - x) / (2*a)
	var time_of_impact = time_of_impact1
	
	if time_of_impact < 0:
		time_of_impact = time_of_impact2
	else:
		if time_of_impact2 >= 0:
			time_of_impact = min(time_of_impact1, time_of_impact2)
	
	var bullet_velocity = target_velocity + Dvec/time_of_impact
	#var calculation_precision = bullet_velocity.length() / bullet_speed
	#print(calculation_precision)
	#if(is_nan(calculation_precision) or calculation_precision < 0.5):
	#	return Vector2.ZERO
	return bullet_velocity.normalized()

func get_state_description():
	if target == null:
		return "Attack is uninitialized!"
	return "Attacking " + target.get_name()
