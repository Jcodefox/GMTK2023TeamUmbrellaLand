extends Node2D

@onready var gravity_area: Area2D = get_node("Gravity")
@onready var gravity_slider: Slider = get_node("CanvasLayer/GravitySlider")

func _ready():
	gravity_slider.value = (gravity_slider.max_value + gravity_slider.min_value) / 2

func _process(delta):
	gravity_area.gravity_direction.y = -gravity_slider.value

