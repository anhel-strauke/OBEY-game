extends Node2D


const CharacterScenes = {
	Constants.Mason:     preload("res://scenes/game/character/characters/Mason.tscn"),
	Constants.Reptiloid: preload("res://scenes/game/character/characters/Reptiloid.tscn"),
	Constants.Tower5G:   preload("res://scenes/game/character/characters/Tower5G.tscn"),
	Constants.Grayman:   preload("res://scenes/game/character/characters/Grayman.tscn")
}

const PlayerDriver = preload("res://scenes/game/character_drivers/PlayerDriver.gd")
const AiDriver = preload("res://scenes/game/character_drivers/AiDriver.gd")


enum State {
	Beginning,
	Game,
	CheckingVictory
}


onready var arena_parent = $Arena
onready var game_hud = $HUDLayer/GameHUD
onready var start_anim = $HUDLayer/StartAnimation
onready var victory_timer = $CheckVictoryTimer

# Game settings
# Should be set before call to start(), then have no effect
var characters_choice = [] # Player1 and player2 characters
var arena_scene_name = "res://scenes/game/arenas/Arena1.tscn"
var music_resource_name = ""


var all_characters = [null, null, null, null]
var state = State.Beginning

func load_arena() -> void:
	var ArenaScene = load(arena_scene_name)
	var arena = ArenaScene.instance()
	arena_parent.add_child(arena)
	arena.position = Vector2.ZERO


func collect_character_spawners(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		if child is CharacterSpawner:
			result.append(child)
		else:
			result += collect_character_spawners(child)
	return result


func find_player_spawner(player_id: int, spawners: Array) -> Node2D:
	for spawner in spawners:
		if spawner.player == player_id + 1:
			return spawner
	return null


func setup_character(character: Character, pos: Vector2) -> void:
	Global.find_bullet_parent().add_child(character)
	character.global_position = pos
	character.connect("died", self, "bury_character")
	# Durty hack
	character.set_look_right(character.global_position.x < 1920.0 / 2.0)


func add_character(character: Character, hud_slot: int) -> void:
	assert(all_characters[hud_slot] == null)
	all_characters[hud_slot] = character


func spawn_characters() -> void:
	all_characters = [null, null, null, null]
	var spawners = collect_character_spawners(arena_parent)
	var characters = CharacterScenes.keys()
	# Spawn player characters
	for player_id in characters_choice.size():
		var spawner = find_player_spawner(player_id, spawners)
		if spawner:
			var char_name = characters_choice[player_id]
			var CharacterScene = CharacterScenes[char_name]
			var character = CharacterScene.instance()
			setup_character(character, spawner.global_position)
			add_character(character, spawner.hud_slot)
			var driver = PlayerDriver.new()
			driver.player_index = player_id
			driver.name = "Driver"
			character.add_child(driver)
			character.driver = driver
			characters.remove(characters.find(char_name))
			spawners.remove(spawners.find(spawner))
			spawner.queue_free()
		else:
			print("No spawner for player #", player_id)
	# Spawn all other characters
	characters.shuffle()
	for char_name in characters:
		if spawners.size() > 0:
			var spawner = spawners[0]
			var CharacterScene = CharacterScenes[char_name]
			var character = CharacterScene.instance()
			setup_character(character, spawner.global_position)
			add_character(character, spawner.hud_slot)
			#var driver = AiDriver.new()
			#driver.name = "Driver"
			#character.add_child(driver)
			#character.driver = driver
			spawners.remove(0)
			spawner.queue_free()


func start() -> void:
	load_arena()
	spawn_characters()
	for i in all_characters.size():
		game_hud.assign_character(all_characters[i], i)
	start_anim.play("start")


func show_start_message():
	game_hud.start_animation()


func bury_character(name: String) -> void:
	for i in all_characters.size():
		if all_characters[i] and all_characters[i].name == name:
			print("Buried ", all_characters[i].name)
			all_characters[i] = null
			break


func number_of_alive_characters() -> int:
	var number = 0
	for ch in all_characters:
		if ch:
			number += 1
	return number


func _process(delta: float) -> void:
	match state:
		State.Game:
			if Input.is_key_pressed(KEY_ESCAPE):
				LoadingScene.run_scene("res://scenes/ui/MenuTest.tscn")
			if number_of_alive_characters() <= 1:
				victory_timer.start()
				state = State.CheckingVictory


func _on_start_animation_finished() -> void:
	Global.game_is_on = true
	state = State.Game


func _on_CheckVictoryTimer_timeout() -> void:
	var winner = ""
	for ch in all_characters:
		if ch:
			winner = ch.display_name
	game_hud.victory_message(winner)


func _on_victory_finished() -> void:
	Global.game_is_on = false
	LoadingScene.run_scene("res://scenes/ui/MenuTest.tscn")
