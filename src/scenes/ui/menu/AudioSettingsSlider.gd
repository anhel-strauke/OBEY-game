extends CustomSlider

onready var sound_volume = $MenuSlider/Slider/MenuController/SoundVolume
onready var music_volume = $MenuSlider/Slider/MenuController/MusicVolume

func _ready() -> void:
	._ready()
	sound_volume.set_process(false)
	music_volume.set_process(false)


func on_show() -> void:
	sound_volume.set_process(true)
	music_volume.set_process(true)


func on_hide() -> void:
	sound_volume.set_process(false)
	music_volume.set_process(false)
