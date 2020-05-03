extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var viewport_path

var viewport: Viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport = get_node(viewport_path)

	$Rendered.texture = viewport.get_texture()
	viewport.get_node('Sprite').position += Vector2(150, 200)
	#weapon_pivot.position += Vector2(150, 200)
	$Shadow.texture = viewport.get_texture()


func _process(delta):
	process_light()

var light_coord = Vector2(1500, 500)

func process_light():
	var shadow: Sprite = $Shadow
	var obj_pos = get_parent().position
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
