extends Node2D
class_name CustomSlider

onready var menu_slider = $MenuSlider
onready var menu_controller = $MenuSlider/Slider/MenuController
onready var title_label = $MenuSlider/Slider/LabelRoot/Label

signal hidden()

func activate_slider(slider: CustomSlider) -> void:
	menu_controller.enabled = false
	slider.visible = true
	slider.show()


func activate_menu() -> void:
	menu_controller.enabled = true


func attach_slider(slider: CustomSlider) -> void:
	slider.connect("hidden", self, "activate_menu")


func _ready():
	menu_slider.connect("hidden", self, "_on_MenuSlider_hidden")

func show():
	menu_slider.show()


func hide():
	menu_slider.hide()


func _on_MenuSlider_hidden():
	emit_signal("hidden")
