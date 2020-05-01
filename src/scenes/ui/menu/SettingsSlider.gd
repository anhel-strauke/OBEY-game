extends CustomSlider


onready var controls_settings = $MenuSlider/Slider/ControlsSettingsSlider
onready var audio_settings = $MenuSlider/Slider/AudioSettingsSlider


func _ready() -> void:
	attach_slider(controls_settings)
	attach_slider(audio_settings)


func _on_Controls_activated() -> void:
	activate_slider(controls_settings)


func _on_Audio_activated():
	activate_slider(audio_settings)
