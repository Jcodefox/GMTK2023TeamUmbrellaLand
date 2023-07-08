extends CharacterBody2D

@onready var levels: Array[String] = [
	"main", "final_win_screen"
]

@export var jump_force: float = 210
@export var walk_speed: float = 70

var walk_left: bool = false
@onready var gravity: float = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY)
var should_jump: bool = false

func _physics_process(delta):
	velocity.x = walk_speed
	velocity.y += delta * gravity
	
#	if is_on_floor() and not was_on_floor and not get_tree().get_frame() < 16:
#		velocity.y -= jump_force * 0.5
#		#get_tree().paused = true
	
	if should_jump and is_on_floor():
		velocity.y -= jump_force
		should_jump = false
	else:
		should_jump = false
	
	move_and_slide()

func _on_win_check_body_entered(body):
	go_to_next_level()

func go_to_next_level():
	var current_level_path: String = get_tree().current_scene.scene_file_path
	var current_level_index: int = levels.find(current_level_path)
	get_tree().change_scene_to_file("res://scenes/" + levels[current_level_index + 1] + ".tscn")

func _on_hole_check_body_exited(body):
	if get_tree().get_frame() < 16:
		return
	if not $HoleCheck.has_overlapping_bodies() and is_on_floor():
		should_jump = true

func _on_enemy_and_wall_check_body_entered(body):
	if is_on_floor():
		should_jump = true

func _on_stomp_check_body_entered(body):
	if body.is_in_group("enemy"):
		velocity.y -= jump_force
		get_node("../GameHandler").enemy_stomped(body)
		
