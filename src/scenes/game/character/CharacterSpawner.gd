extends Node2D
class_name CharacterSpawner


export(int, "Bot", "Player 1", "Player 2") var player: int = 0


func _ready() -> void:
	$Polygon2D.queue_free()
