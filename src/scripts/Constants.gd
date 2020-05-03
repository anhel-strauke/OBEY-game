extends Node

enum Actions {
	Fire,
	AddFire,
	Evade,
	Pause
}


enum CommonActions {
	Up,
	Down,
	Left,
	Right,
	Enter,
	Esc
}


# Not a constant, but *whatever, that will do*
var game_just_started: bool = true
