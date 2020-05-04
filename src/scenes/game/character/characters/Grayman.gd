extends Character


onready var anim_player = $AnimationPlayer


func play_random_walk_animation() -> void:
	var rand = randi() % 4
	if rand == 0:
		if has_weapon():
			anim_player.play("walk_blink_weapon")
		else:
			anim_player.play("walk_blink_noweapon")
	else:
		if has_weapon():
			anim_player.play("walk_weapon")
		else:
			anim_player.play("walk_noweapon")


func play_state_animation(st: int) -> void:
	match st:
		State.Idle:
			if has_weapon():
				anim_player.play("idle_weapon")
			else:
				anim_player.play("idle_noweapon")
		State.Run:
			play_random_walk_animation()


func drop_weapon():
	play_state_animation(state)
	.drop_weapon()
