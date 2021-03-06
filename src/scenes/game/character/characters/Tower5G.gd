extends Character


onready var walk_anim_player = $WalkAnimation


func play_state_animation(st: int) -> void:
	match st:
		State.Idle:
			walk_anim_player.play("idle")
		State.Run:
			play_random_walk_animation()


func play_random_walk_animation():
	var rand = randi() % 4
	if rand == 0:
		walk_anim_player.play("walk_slam")
	else:
		walk_anim_player.play("walk_usual")
