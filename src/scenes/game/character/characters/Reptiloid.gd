extends Character


onready var walk_anim_player = $Sprite/Sprite/WalkAnimation


func play_state_animation(st: int) -> void:
	match st:
		State.Idle:
			walk_anim_player.play("idle")
		State.Run:
			walk_anim_player.play("walk")
