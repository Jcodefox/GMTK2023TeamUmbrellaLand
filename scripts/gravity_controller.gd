extends Node2D

@export var min_gravity: float = -1.0
@export var max_gravity: float = 1.0

@export var gravity_sider_snap: int = 50

var _gravity: float = 0.0
var _initial_position: = Vector2.ZERO
var _mouse_down: bool = false

func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		_initial_position = get_viewport().get_mouse_position()
		_mouse_down = true
	elif Input.is_action_just_released("left_click"):
		_gravity = 0.0
		_mouse_down = false

	if _mouse_down:
		var vertical_delta: = get_viewport().get_mouse_position().y \
			- _initial_position.y

		_gravity = remap(
			snappedf(vertical_delta, gravity_sider_snap),
			-gravity_sider_snap,
			gravity_sider_snap,
			min_gravity,
			max_gravity
		)
	else:
		_gravity = remap(
			Input.get_axis("up", "down"),
			-1, 1,
			min_gravity, max_gravity
		)

	_set_global_gravity(_gravity)

func _set_global_gravity(gravity: float) -> void:
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY,
		gravity * 980
	)
