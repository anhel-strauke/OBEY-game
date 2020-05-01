extends MenuItem

const MAX_VALUE = 16
const STEP = 0.1
const MIN_VOLUME = -40.0
const MAX_VOLUME = 0.0

onready var amount_anim_player = $AmountAnim

export(String) var audio_bus_name: String = ""

var _value

func _set_value(val: int) -> void:
	if val < 0:
		val = 0
	elif val > MAX_VALUE:
		val = MAX_VALUE
	amount_anim_player.play("set_amount")
	amount_anim_player.seek(val * STEP, true)
	amount_anim_player.stop(false)
	_value = val


func _value_to_db(val: int) -> float:
	return (float(val) / MAX_VALUE) * (MAX_VOLUME - MIN_VOLUME) + MIN_VOLUME


func _ready() -> void:
	var bus_id := AudioServer.get_bus_index(audio_bus_name)
	if bus_id < 0:
		set_enabled(false)
		return
	var volume := AudioServer.get_bus_volume_db(bus_id)
	volume = clamp(volume, MIN_VOLUME, MAX_VOLUME)
	var val = int(MAX_VALUE / (MAX_VOLUME - MIN_VOLUME) * (volume - MIN_VOLUME))
	_set_value(val)


func _process(_delta: float) -> void:
	if not selected:
		return
	var change := 0
	if GameInput.is_common_action_just_pressed(Constants.CommonActions.Left):
		change = -1
	elif GameInput.is_common_action_just_pressed(Constants.CommonActions.Right):
		change = 1
	if change != 0:
		var bus_id := AudioServer.get_bus_index(audio_bus_name)
		if bus_id < 0:
			set_enabled(false)
			return
		var new_val = _value + change
		_set_value(new_val)
		var volume = _value_to_db(_value)
		AudioServer.set_bus_volume_db(bus_id, volume)
		AudioServer.set_bus_mute(bus_id, _value == 0)
		click_sound.play()


func activate() -> void:
	pass
