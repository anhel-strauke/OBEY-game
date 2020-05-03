extends Node2D

onready var anim_player = $AnimationPlayer

var preloaded_scenes = {}

var next_scene_name: String = ""

onready var background = $Background

func _ready() -> void:
	background.visible = false
	
	Engine.time_scale = 2


func run_scene(scene_resource: String) -> void:
	if next_scene_name != "":
		return
	next_scene_name = scene_resource
	anim_player.play("show")


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"show":
			var old_scene = get_tree().current_scene
			if old_scene:
				old_scene.queue_free()
			get_tree().change_scene(next_scene_name)
			anim_player.play("hide")
		"hide":
			next_scene_name = ""
