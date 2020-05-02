extends Node2D

onready var anim_player = $AnimationPlayer

var preloaded_scenes = {}

var next_scene_name: String = ""

onready var background = $Background

func _ready() -> void:
	background.visible = false


func run_scene(scene_resource: String) -> void:
	assert(next_scene_name == "")
	next_scene_name = scene_resource
	anim_player.play("show")


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"show":
			var old_scene = get_tree().current_scene
			if old_scene:
				old_scene.queue_free()
			#var preloaded_res = preloaded_scenes.get(next_scene_name, null)
			#if not preloaded_res:
			#	preloaded_res = load(next_scene_name)
			#	preloaded_scenes[next_scene_name] = preloaded_res
			#var scene = preloaded_res.instance()
			get_tree().change_scene(next_scene_name)
			anim_player.play("hide")
		"hide":
			next_scene_name = ""
