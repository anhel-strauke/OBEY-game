extends CustomSlider


onready var controls_settings = $MenuSlider/Slider/ControlsSettingsSlider


func _ready() -> void:
	attach_slider(controls_settings)


func _on_Controls_activated() -> void:
	activate_slider(controls_settings)

