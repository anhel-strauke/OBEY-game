extends Node2D


onready var items = [
	$ReptiloidMenuItem,
	$MasonMenuItem,
	$GraymanMenuItem,
	$Tower5GMenuItem
]

enum State {
	Selecting,
	Finishing
}

var selections = [-1, -1]
var accepted = [false, false]
var direction_was_pressed = [false, false]
var players = 1

var state = State.Selecting

signal selected(player, character)
signal accepted(player, character)
signal rejected(player)
signal finished_selection()
signal cancelled()


func rotate_menu_item(item: int, dir: int) -> int:
	var next = item + dir
	if next >= items.size():
		next = 0
	elif next < 0:
		next = items.size() - 1
	return next


func get_next_selection_for(player_id: int, dir: int) -> int:
	var current = selections[player_id]
	var other_current = selections[1 - player_id]
	var next = rotate_menu_item(current, dir)
	while next == other_current:
		next = rotate_menu_item(next, dir)
	return next


func set_players(p: int) -> void:
	players = p
	for i in items.size():
		var item = items[i]
		var player_id = Global.last_selected_chars.find(item.character_name)
		if player_id >= 0 and player_id < players:
			selections[player_id] = i
			item.select(player_id)
			emit_signal("selected", player_id, item.character_name)
		else:
			item.deselect()
	for i in players:
		if selections[i] < 0:
			selections[i] = get_next_selection_for(i, 1)
			items[selections[i]].select(i)
			emit_signal("selected", i, items[selections[i]].character_name)


func select_next_item(player_id: int, dir: int) -> void:
	var index = selections[player_id]
	items[index].deselect()
	index = get_next_selection_for(player_id, dir)
	items[index].select(player_id)
	selections[player_id] = index
	emit_signal("selected", player_id, items[index].character_name)


func _process(_delta: float) -> void:
	if state == State.Selecting:
		if Input.is_action_just_pressed("ui_cancel"):
			emit_signal("cancelled")
			state = State.Finishing
		for i in players:
			if not accepted[i] and GameInput.player(i).is_just_pressed(Constants.Actions.Fire):
				accepted[i] = true
				items[selections[i]].accept()
				emit_signal("accepted", i, items[selections[i]].character_name)
			elif GameInput.player(i).is_just_pressed(Constants.Actions.AddFire):
				if accepted[i]:
					accepted[i] = false
					items[selections[i]].select(i)
					emit_signal("rejected", i)
				else:
					emit_signal("cancelled")
					state = State.Finishing
			elif not accepted[i]:
				var direction = GameInput.player(i).direction()
				if abs(direction.y) >= 0.6:
					if not direction_was_pressed[i]:
						if direction.y < 0:
							select_next_item(i, -1)
						elif direction.y > 0:
							select_next_item(i, 1)
						direction_was_pressed[i] = true
				else:
					direction_was_pressed[i] = false
		var need_finish = true
		for i in players:
			if not accepted[i]:
				need_finish = false
				break
		if need_finish:
			emit_signal("finished_selection")
			state = State.Finishing


func selected_character_name(player_id: int) -> String:
	if selections[player_id] >= 0:
		return items[selections[player_id]].character_name
	return ""
