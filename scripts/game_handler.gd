extends Node2D

var is_clicked: bool = false
var offset: Vector2 = Vector2.ZERO
var handled_enemy: PhysicsBody2D = null
var mouse_over_trash: bool = false
var tween: Tween = null
func enemy_stomped(enemy: PhysicsBody2D):
	enemy.scale.y = 0.75
	enemy.position.y += 2
	enemy.z_index = 10
	handled_enemy = enemy
	enemy.input_event.connect(enemy_input_event)
	enemy.process_mode = Node.PROCESS_MODE_ALWAYS
	enemy.can_move = false
	get_node("../CanvasLayer/Trash").visible = true
	get_tree().paused = true
	tween = get_tree().create_tween()
	$ColorRect.color.a = 0.75
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 3)
	tween.tween_callback(finish_tween)

func finish_tween():
	tween = null
	get_node("../CanvasLayer/Trash").visible = false
	if handled_enemy != null:
		handled_enemy.process_mode = PROCESS_MODE_INHERIT
		$ColorRect.color = Color(0, 0, 0, 0.9)
		get_node("../CanvasLayer/Lose").visible = true
	else:
		$ColorRect.color = Color(0, 0, 0, 0)
		get_tree().paused = false

func _process(delta):
	if not is_clicked:
		return
	is_clicked = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if not is_clicked and mouse_over_trash:
		handled_enemy.queue_free()
		handled_enemy = null
		tween.stop()
		finish_tween()
		return
	if handled_enemy == null:
		return
	handled_enemy.position = get_global_mouse_position() + offset

func enemy_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if not event is InputEventMouseButton:
		return
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return
	
	if event.pressed:
		offset = handled_enemy.position - get_global_mouse_position()
		is_clicked = true

func _on_trash_mouse_over_change(mouse_over: bool):
	mouse_over_trash = mouse_over
