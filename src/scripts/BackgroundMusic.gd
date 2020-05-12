extends Node


class _StatefulPlayer:
	enum _PlayerState {
		FadeIn,
		Playing,
		FadeOut
	}
	var state: int = _PlayerState.FadeIn
	var player: AudioStreamPlayer = null
	var tween: Tween = null
	var parent: Node = null
	var silence_volume: float = -60.0
	var loud_volume: float = -10.0
	
	signal stopped(stateful_player)
	
	func _init(parent: Node, stream: AudioStream, silence: float, loud: float) -> void:
		self.parent = parent
		player = AudioStreamPlayer.new()
		player.bus = "Music"
		player.stream = stream
		parent.add_child(player)
		tween = Tween.new()
		parent.add_child(tween)
		silence_volume = silence
		loud_volume = loud
	
	func destroy() -> void:
		player.queue_free()
		tween.queue_free()
	
	func play(fade: float = 0.0) -> void:
		var do_fade_in = not is_zero_approx(fade)
		if do_fade_in:
			state = _PlayerState.FadeIn
			player.volume_db = silence_volume
			player.play()
			_connect_tween("_move_to_playing_state")
			_setup_tween(silence_volume, loud_volume, fade)
			tween.start()
		else:
			state = _PlayerState.Playing
			player.volume_db = loud_volume
			player.play()
	
	func stop(fade: float = 0.0) -> void:
		var do_fade_out = not is_zero_approx(fade)
		match state:
			_PlayerState.FadeIn:
				state = _PlayerState.FadeOut
				if do_fade_out:
					var fade_in_left = tween.get_runtime() - tween.tell()
					var fade_out_start = fade_in_left * fade / tween.get_runtime()
					_disconnect_tween()
					tween.stop_all()
					_setup_tween(loud_volume, silence_volume, fade)
					_connect_tween("_finish")
					tween.start()
					tween.seek(fade_out_start)
				else:
					_disconnect_tween()
					_stop_immediately()
			_PlayerState.Playing:
				state = _PlayerState.FadeOut
				if do_fade_out:
					_setup_tween(loud_volume, silence_volume, fade)
					_connect_tween("_finish")
					tween.start()
				else:
					_stop_immediately()
	
	func _stop_immediately() -> void:
		player.stop()
		tween.stop_all()
		emit_signal("stopped", self)
	
	func _setup_tween(vol_from: float, vol_to: float, fade: float) -> void:
		tween.interpolate_property(player, "volume_db", vol_from, vol_to, fade, Tween.TRANS_SINE)
	
	func _connect_tween(method: String) -> void:
		tween.connect("tween_all_completed", self, method)
	
	func _disconnect_tween() -> void:
		if tween.is_connected("tween_all_completed", self, "_move_to_playing_state"):
			tween.disconnect("tween_all_completed", self, "_move_to_playing_state")
		if tween.is_connected("tween_all_completed", self, "_finish"):
			tween.disconnect("tween_all_completed", self, "_finish")
		tween.remove_all()
	
	func _move_to_playing_state() -> void:
		_disconnect_tween()
		state = _PlayerState.Playing
	
	func _finish() -> void:
		_disconnect_tween()
		player.stop()
		emit_signal("stopped", self)



var _players := []
var _next_resource = null
var _next_fade_in: float = 0.0

var volume_silence := -60.0
var volume_loud := -10.0
var fade_time := 0.5

signal music_is_over()


func _destroy_player_and_go_on(player: _StatefulPlayer) -> void:
	var i = _players.find(player)
	if i >= 0:
		_players.remove(i)
	player.destroy()
	if _players.size() == 0:
		if _next_resource:
			if is_zero_approx(_next_fade_in):
				set_immediately(_next_resource)
			else:
				set_crossfade(_next_resource, _next_fade_in)
	else:
		emit_signal("music_is_over")


func _load_music_resource(resource_or_name) -> AudioStream:
	var stream = null
	if resource_or_name is String:
		stream = load(resource_or_name)
		if not (stream is AudioStream):
			printerr("Not an audio stream: '", resource_or_name, "'")
			return null
	elif resource_or_name is AudioStream:
		stream = resource_or_name
	return stream


func _make_fade_time(fade) -> float:
	if fade < 0:
		return fade_time
	return float(fade)


func _create_player(stream: AudioStream, vol_silence: float, vol_loud: float) -> _StatefulPlayer:
	var player = _StatefulPlayer.new(self, stream, vol_silence, vol_loud)
	player.connect("stopped", self, "_destroy_player_and_go_on")
	_players.append(player)
	return player


func set_immediately(music_resource) -> void:
	for player in _players:
		player.stop()
	_next_resource = null
	var stream := _load_music_resource(music_resource)
	if stream:
		var new_player = _create_player(stream, volume_silence, volume_loud)
		new_player.play()


func set_crossfade(music_resource, fade=-1) -> void:
	for player in _players:
		player.stop(fade)
	_next_resource = null
	fade = _make_fade_time(fade)
	var stream = _load_music_resource(music_resource)
	if stream:
		var new_player = _create_player(stream, volume_silence, volume_loud)
		new_player.play(fade)


func set_with_fade(music_resource, fade=-1) -> void:
	fade = _make_fade_time(fade)
	if _players.size() == 0:
		set_crossfade(music_resource, fade)
	else:
		_next_resource = music_resource
		_next_fade_in = fade
		for player in _players:
			player.stop(fade)


func stop_with_fade(fade=-1) -> void:
	_next_resource = null
	fade = _make_fade_time(fade)
	for player in _players:
		player.stop(fade)


func stop_immediately() -> void:
	_next_resource = null
	for player in _players:
		player.stop()

