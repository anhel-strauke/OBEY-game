extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var viewport_path

var viewport: Viewport
var obj_pos
var shadows = []
# Called when the node enters the scene tree for the first time.
func _ready():
	viewport = get_node(viewport_path)

	$Rendered.texture = viewport.get_texture()
	viewport.get_node('Sprite').position += Vector2(150, 200)
	#weapon_pivot.position += Vector2(150, 200)
	$Shadow.texture = viewport.get_texture()


func _process(delta):
	obj_pos = get_parent().position
	var light_system = get_light_system()
	if not light_system:
		return
	var cur_shadow_count = 0
	for light in light_system.lights.values():
		cur_shadow_count += 1
		var shadow
		if cur_shadow_count > len(shadows):
			shadow = Sprite.new()
			add_child(shadow)
			shadows.append(shadow)
			shadow.texture = viewport.get_texture()
		else:
			shadow = shadows[cur_shadow_count - 1]
		process_light(light, shadow)
	for i in range(cur_shadow_count, len(shadows)):
		var shadow = shadows.pop_back()
		shadow.queue_free()
	
func get_light_system():
	return get_tree().get_root().get_node("World").get_node("LightSystem")

func process_light(light, shadow: Sprite):
	var light_coord = light.position
	
	var lvec = obj_pos - light_coord
	var ldirection = atan2(lvec.y, lvec.x)
	
	
	var falloff = (500.0 - lvec.length())/500.0
	shadow.self_modulate = Color(0.3, 0.3, 0.3, clamp(falloff, 0, 1))
	
	shadow.modulate = Color(0.3, 0.3, 0.3, 1.0)
#	shadow.rotation = ldirection + PI/2.0
#	var sc = (ldirection - PI)/PI*2.0
#	if abs(sc) < 0.1:
#		sc = sign(sc)*0.1
#	shadow.scale.x = sc

#	shadow.rotation = abs(ldirection) + PI/2.0
#	var hv_sign = sign(ldirection)
#	var sc = (PI/2.0 - abs(abs(ldirection) - PI/2.0))/PI*2.0
#	if sc < 0.1:
#		sc = 0.1
#	var rl_sign = -sign(abs(ldirection) - PI/2.0)
##	shadow.scale.x = -sc*hv_sign
##	shadow.scale.y = hv_sign*rl_sign
#	shadow.scale.x = sc*rl_sign
#	shadow.scale.y = hv_sign

	#shadow.rotation = abs(abs(ldirection) - PI/2.0) + PI/2.0    + PI/2.0
	
	
	#shadow.rotation = abs(abs(ldirection) - PI/2.0)# + PI/2.0    + PI/2.0
	
	#print("rot: ", shadow.rotation)
	# var hv_sign = sign(ldirection)
	var hv_sign = 1.0 if lvec.y > 0 else -1.0
	var rl_sign = 1.0 if lvec.x > 0 else -1.0
	var sc = (PI/2.0 - abs(abs(ldirection) - PI/2.0))/PI*2.0
	if sc < 0.3:
		sc = 0.3
	# var rl_sign = -sign(abs(ldirection) - PI/2.0)
#	shadow.scale.x = -sc*hv_sign
#	shadow.scale.y = hv_sign*rl_sign
	shadow.scale.x = sc
	shadow.scale.y = -hv_sign
	
	shadow.rotation = -abs(abs(ldirection) - PI/2.0)*hv_sign*rl_sign# + PI/2.0    + PI/2.0
#	print("rl: ", rl_sign, "hv: ", hv_sign)
	# print("sc_sign: ", sign(sc))
