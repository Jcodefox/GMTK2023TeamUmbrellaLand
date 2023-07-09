extends CharacterBody2D

@onready var levels: Array[String] = [
	"res://scenes/tutorial.tscn",
	"res://scenes/level_1.tscn",
	"res://scenes/level_2.tscn",
	"res://scenes/level_3.tscn",
	"res://scenes/level_4.tscn",
	"res://scenes/level_5.tscn",
	"res://scenes/final_win_screen.tscn"
]

@export var jump_force: float = 210
@export var walk_speed: float = 70
var jump_multiplier: float = 1

var walk_left: bool = false
@onready var gravity: float = PhysicsServer2D.area_get_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY)
var should_jump: bool = false
var can_jump: bool = false
var was_grounded: bool = true

func _ready():
	get_tree().create_timer(0.25).timeout.connect(func():
		can_jump = true
	)
	if get_tree().current_scene.scene_file_path == levels[0]:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		GameHandler.tutorial_mode(true)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameHandler.tutorial_mode(false)

func _physics_process(delta):
	velocity.x = walk_speed
	velocity.y += delta * gravity
	
	if not $AudioStreamPlayer2D.playing and is_on_floor():
		$AudioStreamPlayer2D.play()
	if not is_on_floor():
		$AudioStreamPlayer2D.stop()
	
	if should_jump:
		velocity.y -= jump_force * jump_multiplier
		should_jump = false
		$Jump.play()
	if is_on_floor() and not was_grounded:
		$Land.play()
	was_grounded = is_on_floor()
	
	move_and_slide()

func _on_win_check_body_entered(body):
	go_to_next_level()

func go_to_next_level():
	var current_level_path: String = get_tree().current_scene.scene_file_path
	var current_level_index: int = levels.find(current_level_path)
	GameHandler.coins_in_this_round = 0
	get_tree().change_scene_to_file(levels[current_level_index + 1])

func _on_hole_check_body_exited(body):
	if not can_jump:
		return
	if not $HoleCheck.has_overlapping_bodies() and is_on_floor():
		should_jump = true
		jump_multiplier = 2

func _on_enemy_and_wall_check_body_entered(body):
	if is_on_floor() and body.is_in_group("enemy"):
		should_jump = true
		jump_multiplier = 1
	if is_on_floor() and not body.is_in_group("enemy"):
		jump_multiplier = 1
		get_tree().create_timer(0.3).timeout.connect(func():
			should_jump = true
		)

func _on_stomp_check_body_entered(body):
	if body.is_in_group("enemy"):
		should_jump = true
		jump_multiplier = 1
		$Boom.play()
		GameHandler.enemy_stomped(body)

func _on_coin_check_area_entered(area):
	if area.is_in_group("coin"):
		GameHandler.coin_collected()
		area.visible = false
		area.queue_free()
