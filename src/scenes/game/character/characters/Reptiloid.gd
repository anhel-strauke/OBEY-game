extends Character


onready var walk_anim_player = $WalkAnimation


func play_state_animation(st: int) -> void:
	match st:
		State.Idle:
			if has_weapon():
				walk_anim_player.play("idle")
			else:
				walk_anim_player.play("idle_no_weapon")
		State.Run:
			if has_weapon():
				walk_anim_player.play("walk")
			else:
				walk_anim_player.play("walk_no_weapon")


func drop_weapon():
	play_state_animation(state)
	.drop_weapon()
