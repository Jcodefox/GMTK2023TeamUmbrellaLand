extends CharacterBody2D

@onready var gravity_area: Area2D = get_node("../gravity")

var walk_speed: float = 70
var walk_left: bool = false

func _ready():
	pass

func _process(delta):
	if is_on_wall():
		walk_left = get_wall_normal().x < -0.5
		$Sprite.flip_h = walk_left
	if is_on_floor():
		velocity.x = walk_speed * (-1 if walk_left else 1)
	velocity += delta * gravity_area.gravity_direction * gravity_area.gravity
	move_and_slide()
