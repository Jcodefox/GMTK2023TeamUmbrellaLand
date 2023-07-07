extends Node2D

@onready var gravity_slider: Slider = get_node("CanvasLayer/GravitySlider")

func _ready():
	gravity_slider.value = (gravity_slider.max_value + gravity_slider.min_value) / 2

func _process(delta):
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY, -gravity_slider.value * 980)

