extends Node2D


const CharacterScenes = {
	Constants.Mason:     preload("res://scenes/game/character/characters/Mason.tscn"),
	Constants.Reptiloid: preload("res://scenes/game/character/characters/Reptiloid.tscn"),
	Constants.Tower5G:   preload("res://scenes/game/character/characters/Tower5G.tscn"),
	Constants.Grayman:   preload("res://scenes/game/character/characters/Grayman.tscn")
}

const PlayerDriver = preload("res://scenes/game/character_drivers/PlayerDriver.gd")
const AiDriver = preload("res://scenes/game/character_drivers/MediumBotDriver.tscn")


enum State {
	Beginning,
	Game,
	CheckingVictory
}


onready var arena_parent = $Arena
onready var game_hud = $HUDLayer/GameHUD
onready var start_anim = $BlackLayer/StartAnimation
onready var victory_timer = $CheckVictoryTimer

const music_resources = [
	"res://sounds/music/ArenaY.ogg",
	"res://sounds/music/ArenaX.ogg",
	"res://sounds/music/ArenaP.ogg"
]

# Game settings
# Should be set before call to start(), then have no effect
var characters_choice = [] # Player1 and player2 characters
var arena_scene_name = "res://scenes/game/arenas/Arena1.tscn"
var music_resource_name = ""


var all_characters = [null, null, null, null]
var dead_character_names = []
var state = State.Beginning


func _ready() -> void:
	Global.game_is_on = false


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
			driver.connect("sequence_completed", character, "become_immortal")
			characters.remove(characters.find(char_name))
			spawners.remove(spawners.find(spawner))
			spawner.queue_free()
		else:
			print("No spawner for player #", player_id)
	# Spawn all other characters
	characters.shuffle()
	#var navigation = get_tree().get_nodes_in_group('pathfinder_singleton')[0]
	var aidrivers = []
	for char_name in characters:
		if spawners.size() > 0:
			var spawner = spawners[0]
			var CharacterScene = CharacterScenes[char_name]
			var character = CharacterScene.instance()
			# Reduce bots' hitpoints
			# TODO: In the future bot's hitpoints will depend on the
			#       difficulty level of the game
			character.max_hitpoints = character.max_hitpoints / 2
			character._hp = character.max_hitpoints
			setup_character(character, spawner.global_position)
			add_character(character, spawner.hud_slot)
			var driver = AiDriver.instance()
			aidrivers.append(driver)
			driver.name = "Driver"
			character.add_child(driver)
			character.driver = driver
			#driver.navigation = navigation
			spawners.remove(0)
			spawner.queue_free()
	for aidriver in aidrivers:
		aidriver._on_all_players_ready()
	# fixme: import of navigation
	aidrivers[0].navigation._on_all_players_ready() 


func start() -> void:
	load_arena()
	spawn_characters()
	game_hud.update_controls_hints(characters_choice.size())
	for i in all_characters.size():
		game_hud.assign_character(all_characters[i], i)
	start_anim.play("start")
	BackgroundMusic.set_with_fade(music_resources[randi() % music_resources.size()])


func show_start_message():
	game_hud.start_animation()


func bury_character(name: String) -> void:
	dead_character_names.append(name)
	for i in all_characters.size():
		if all_characters[i] and all_characters[i].name == name:
			print("Buried ", all_characters[i].name)
			all_characters[i] = null
			break
	var player_is_dead = [false, false]
	for player_id in len(characters_choice):
		player_is_dead[player_id] = dead_character_names.has(characters_choice[player_id])
	game_hud.dead_player_characters = player_is_dead


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
	BackgroundMusic.stop_with_fade()
	Global.game_is_on = false
	if characters_choice.size() == 1:
		LoadingScene.run_scene("res://scenes/ui/character_selection/CharacterSelectionScene1.tscn")
	else:
		LoadingScene.run_scene("res://scenes/ui/character_selection/CharacterSelectionScene2.tscn")
