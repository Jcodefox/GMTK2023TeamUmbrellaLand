extends Node2D

@onready var gravity_area: Area2D = get_node("gravity")

func _process(delta):
	if Input.is_action_just_pressed("swap_gravity"):
		gravity_area.gravity_direction.y = -gravity_area.gravity_direction.y
