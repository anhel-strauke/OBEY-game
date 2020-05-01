extends Node2D
class_name MenuController


export(bool) var enabled = true setget set_enabled
export(bool) var can_be_cancelled = true

var menu_items: Array = []
var current_index = 0 setget set_current_index

signal item_pressed(index)
signal cancelled()
signal enabled_and_can_be_cancelled(can)

class _YSortCompare:
	static func compare(a: MenuItem, b: MenuItem) -> bool:
		return a.global_position.y < b.global_position.y


func _rotate_menu_index(i: int) -> int:
	if i < 0:
		return i + menu_items.size()
	elif i >= menu_items.size():
		return i - menu_items.size()
	return i


func find_next_enabled_item(current: int, forward: bool) -> int:
	var dir := -1
	if forward:
		dir = 1
	var i := _rotate_menu_index(current + dir)
	while i != current:
		if menu_items[i].enabled:
			return i
		i = _rotate_menu_index(i + dir)
	if menu_items[i].enabled:
		return i
	return -1


func _deselect_current():
	if current_index >= 0:
		menu_items[current_index].set_selected(false)


func _select_next():
	_deselect_current()
	var start_index = current_index
	if start_index < 0:
		start_index = menu_items.size() - 1
	var next = find_next_enabled_item(start_index, true)
	if next >= 0:
		menu_items[next].set_selected(true)
	current_index = next


func _select_prev():
	_deselect_current()
	var start_index = current_index
	if start_index < 0:
		start_index = 0
	var prev = find_next_enabled_item(start_index, false)
	if prev >= 0:
		menu_items[prev].set_selected(true)
	current_index = prev


func _ready() -> void:
	for child in get_children():
		if child is MenuItem:
			var item := child as MenuItem
			item.set_selected_immed(false)
			menu_items.append(item)
	if menu_items.size() > 0:
		menu_items.sort_custom(_YSortCompare, "compare")
		current_index = menu_items.size() - 1
		var first_enabled := find_next_enabled_item(current_index, true)
		if first_enabled >= 0:
			current_index = first_enabled
			menu_items[first_enabled].set_selected_immed(true)
		else:
			current_index = -1


func _process(_delta: float) -> void:
	if not enabled:
		return
	if menu_items.size() == 0:
		return
	if GameInput.is_common_action_just_pressed(Constants.CommonActions.Down):
		_select_next()
	elif GameInput.is_common_action_just_pressed(Constants.CommonActions.Up):
		_select_prev()
	elif GameInput.is_common_action_just_pressed(Constants.CommonActions.Enter):
		if current_index >= 0:
			emit_signal("item_pressed", current_index)
			menu_items[current_index].activate()
	elif can_be_cancelled and GameInput.is_common_action_just_pressed(Constants.CommonActions.Esc):
		emit_signal("cancelled")


func set_enabled(en: bool) -> void:
	enabled = en


func set_current_index(index: int) -> void:
	if index >= 0 and index < menu_items.size():
		if index != current_index:
			_deselect_current()
			if not menu_items[index].enabled:
				index = find_next_enabled_item(index, true)
			if index >= 0:
				menu_items[index].set_selected_immed(true)
				current_index = index
