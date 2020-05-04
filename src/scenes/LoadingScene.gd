extends Node2D

onready var anim_player = $AnimationPlayer

const GameSceneName = "res://scenes/game/Game.tscn"

var preloaded_scenes = {
	GameSceneName: preload("res://scenes/game/Game.tscn")
}

var next_scene_name: String = ""
var _player_chars: Array = []
var _arena_name: String = ""
var _music_resource: String = ""

onready var background = $CanvasLayer/Background

func _ready() -> void:
	background.visible = false


func run_scene(scene_resource: String) -> void:
	if next_scene_name != "":
		return
	next_scene_name = scene_resource
	anim_player.play("show")


func run_game_arena(player_chars: Array, arena_scene: String, music_resource: String) -> void:
	_player_chars = player_chars
	_arena_name = arena_scene
	_music_resource = music_resource
	run_scene(GameSceneName)


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"show":
			var old_scene = get_tree().current_scene
			if old_scene.has_method("_before_free"):
				old_scene._before_free()
			if old_scene:
				old_scene.queue_free()
			get_tree().change_scene(next_scene_name)
			anim_player.play("hide")
		"hide":
			if next_scene_name == GameSceneName:
				var game = get_tree().current_scene
				game.characters_choice = _player_chars
				game.arena_scene_name = _arena_name
				game.music_resource_name = _music_resource
				game.start()
			next_scene_name = ""
