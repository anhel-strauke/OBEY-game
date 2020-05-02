extends "res://scenes/game/character_drivers/aistates/StageAwareState.gd"

var target

func initialize(newTarget):
	target = newTarget

func update(Variant):
	._update()
	# var aim_direction = player.position.direction_to(target.position)
	#get_simple_path(start_position, end_position, true)
	var aim_direction = predict_without_acceleration()
	velocity_vector = aim_direction # / 10000 # fixme: stop on "shoot" to visualize cooldown
	# var distance = player.position.distance_to(target.position)
	
# To make it more accurate, we can do:
# 1. Add acceleration to the equation
# 2. Consider _changing_ acceleration
# 3. Record patterns of acceleration changes to predict target's dodging
func predict_without_acceleration():
	var bullet_origin = player.global_position # TODO: Take gun anchor into account
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
