extends Node2D

@onready var gravity_area: Area2D = get_node("Gravity")
@onready var gravity_slider: Slider = get_node("CanvasLayer/GravitySlider")

func _process(delta):
	gravity_area.gravity_direction.y = -gravity_slider.value + 5

