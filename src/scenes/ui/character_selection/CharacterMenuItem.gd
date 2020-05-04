extends Node2D


onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var active_sprite = $SpriteRoot
onready var inactive_sprite = $InactiveSpriteRoot
onready var players = [
	$Player1,
	$Player2
]

export(String) var character_name


func _ready() -> void:
	deselect()


func deselect() -> void:
	active_sprite.visible = false
	inactive_sprite.visible = true
	for p in players:
		p.visible = false


func select(by_player: int) -> void:
	active_sprite.visible = true
	inactive_sprite.visible = false
	anim_player.play("active")
	players[by_player].visible = true


func accept() -> void:
	active_sprite.visible = true
	inactive_sprite.visible = false
	anim_player.play("active")
	for p in players:
		p.visible = false
