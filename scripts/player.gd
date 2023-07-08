extends CharacterBody2D

@onready var levels: Array[String] = [
	"main", "final_win_screen"
]

var walk_speed: float = 70
var walk_left: bool = false
var gravity: float

func _process(delta):
	gravity = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY)
	if is_on_wall():
		walk_left = get_wall_normal().x < -0.5
		$Sprite.flip_h = walk_left
	velocity.x = walk_speed * (-1 if walk_left else 1)
	velocity.y += delta * gravity
	
	move_and_slide()

func _on_win_check_body_entered(body):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Sprite, "modulate", Color(1,1,1,0), 1)
	tween.tween_interval(0.1)
	tween.tween_callback(go_to_next_level)

func go_to_next_level():
	var current_level_path: String = get_tree().current_scene.scene_file_path
	var current_level_index: int = levels.find(current_level_path)
	get_tree().change_scene_to_file("res://scenes/" + levels[current_level_index + 1] + ".tscn")

func _on_lose_check_body_entered(body):
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	tween1.tween_property($Camera2D, "zoom", Vector2(20, 20), 1)
	tween2.tween_property($Camera2D, "rotation", 4 * PI, 1)
	tween2.tween_interval(0.1)
	tween2.tween_callback(restart_level)

func restart_level():
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
