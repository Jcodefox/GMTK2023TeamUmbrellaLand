extends Node2D

var is_clicked: bool = false
var has_clicked: bool = false
var offset: Vector2 = Vector2.ZERO
var handled_enemy: PhysicsBody2D = null
var mouse_over_trash: bool = false
var enemy_tween: Tween = null
var coin_tween: Tween = null
var cursor_tween: Tween = null

var coins: int = 0
var coins_uncounted: int = 0
var coins_in_this_round: int = 0

func tutorial_mode(on: bool):
	coins_uncounted = 0
	is_clicked = false
	has_clicked = false
	mouse_over_trash = false
	$Canvas/CursorTutorial.visible = on
	if not on:
		if not UI.get_node("CoinButton").pressed.is_connected(coin_button_press):
			UI.get_node("CoinButton").pressed.connect(coin_button_press)
	else:
		if UI.get_node("CoinButton").pressed.is_connected(coin_button_press):
			UI.get_node("CoinButton").pressed.disconnect(coin_button_press)

func _ready():
	UI.get_node("Trash").mouse_entered.connect(_on_trash_mouse_over_change.bind(true))
	UI.get_node("Trash").mouse_exited.connect(_on_trash_mouse_over_change.bind(false))
	UI.get_node("Lose/Button").pressed.connect(reload_level)

func reload_level():
	UI.get_node("CoinButton").visible = false
	coins -= coins_in_this_round
	coins_in_this_round = 0
	UI.get_node("Coins").text = "$" + str(coins)
	if enemy_tween:
		enemy_tween.stop()
		enemy_tween = null
	if coin_tween:
		coin_tween.stop()
		coin_tween = null
	is_clicked = false
	has_clicked = false
	handled_enemy = null
	UI.get_node("Trash").visible = false
	UI.get_node("TimeBar").visible = false
	UI.get_node("Lose").visible = false
	$Music.pitch_scale = 1
	$ColorRect.color = Color(0, 0, 0, 0)
	coins_uncounted = 0
	get_tree().paused = false
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func enemy_stomped(enemy: PhysicsBody2D):
	enemy.get_node("AnimatedSprite2D").animation = "dead" 
	enemy.z_index = 10
	handled_enemy = enemy
	enemy.input_event.connect(enemy_input_event)
	enemy.process_mode = Node.PROCESS_MODE_ALWAYS
	enemy.can_move = false
	has_clicked = false
	UI.get_node("Trash").visible = true
	UI.get_node("TimeBar").visible = true
	UI.get_node("TimeBar").value = 0
	get_tree().paused = true
	enemy_tween = create_tween()
	$ColorRect.color.a = 0.75
	enemy_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	enemy_tween.tween_property($Music, "pitch_scale", 0.4, 1)
	enemy_tween.parallel()
	enemy_tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 2)
	enemy_tween.parallel()
	enemy_tween.tween_property(UI.get_node("TimeBar"), "value", 100, 2)
	enemy_tween.tween_callback(finish_tween)
	
	if not $Canvas/CursorTutorial.visible:
		return
	if cursor_tween:
		cursor_tween.stop()
		cursor_tween = null
	cursor_tween = create_tween()
	get_viewport().position
	Input.warp_mouse(UI.get_node("Trash").position + UI.get_node("Trash").size)
	var diff: Vector2 = (UI.get_node("Trash").global_position + UI.get_node("Trash").size) - handled_enemy.get_global_transform_with_canvas().origin
	cursor_tween.tween_property($Canvas/CursorTutorial, "position", handled_enemy.get_global_transform_with_canvas().origin, 0.5)
	cursor_tween.tween_interval(0.1)
	cursor_tween.tween_property($Canvas/CursorTutorial, "position", UI.get_node("Trash").position + UI.get_node("Trash").size, 1)
	cursor_tween.parallel()
	cursor_tween.tween_property(handled_enemy, "global_position", handled_enemy.global_position + diff * 0.333, 1)
	cursor_tween.tween_callback(func():
		handled_enemy.queue_free()
		handled_enemy = null
		if enemy_tween:
			enemy_tween.stop()
		finish_tween()
	)
	cursor_tween.tween_property($Canvas/CursorTutorial, "global_position", get_viewport_rect().size / 2, 1)
	Input.warp_mouse(get_viewport_rect().size / 2)

func finish_tween():
	mouse_over_trash = false
	has_clicked = false
	enemy_tween = null
	UI.get_node("Trash").visible = false
	UI.get_node("TimeBar").visible = false
	if handled_enemy != null:
		handled_enemy.process_mode = PROCESS_MODE_INHERIT
		$ColorRect.color = Color(0, 0, 0, 0.9)
		UI.get_node("Lose").visible = true
		UI.get_node("Lose").text = "The enemy did not disappear as the player expected!\nThe player rage quit!"
	else:
		$Music.pitch_scale = 1
		$ColorRect.color = Color(0, 0, 0, 0)
		get_tree().paused = false

func _process(delta):
	if UI.get_node("Lose").visible:
		return
	if is_clicked:
		is_clicked = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if has_clicked and not is_clicked and mouse_over_trash:
		handled_enemy.queue_free()
		handled_enemy = null
		if enemy_tween:
			enemy_tween.stop()
		finish_tween()
		return
	if handled_enemy == null:
		return
	if has_clicked:
		handled_enemy.position = get_global_mouse_position() + offset

func enemy_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if not event is InputEventMouseButton:
		return
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		offset = handled_enemy.position - get_global_mouse_position()
		is_clicked = true
		has_clicked = true

func coin_collected():
	$CoinSound.play()
	coins_uncounted += 1
	UI.get_node("CoinButton").text = "+1/" + str(coins_uncounted)
	UI.get_node("CoinButton").visible = true
	if coin_tween != null:
		coin_tween.stop()
		coin_tween = null
	coin_tween = create_tween()
	UI.get_node("CoinButton").modulate = Color.WHITE
	coin_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	coin_tween.tween_property(UI.get_node("CoinButton"), "modulate", Color(1, 1, 1, 0), 3)
	coin_tween.tween_callback(func():
		get_tree().paused = true
		UI.get_node("Lose").visible = true
		UI.get_node("Lose").text = "The coin counter didn't go up as the player expected!\nThe player rage quit!"
		UI.get_node("Trash").visible = false
		UI.get_node("TimeBar").visible = false
		$ColorRect.color = Color(0, 0, 0, 0.9)
		if handled_enemy != null:
			handled_enemy.process_mode = PROCESS_MODE_INHERIT
			handled_enemy.z_index = 0
			if enemy_tween:
				enemy_tween.stop()
			enemy_tween = null
	)
	
	if not $Canvas/CursorTutorial.visible:
		return
	if cursor_tween:
		cursor_tween.stop()
		cursor_tween = null
	cursor_tween = create_tween()
	cursor_tween.tween_property($Canvas/CursorTutorial, "position", \
		UI.get_node("CoinButton").position + UI.get_node("CoinButton").size / 2, 0.5)
	cursor_tween.tween_interval(0.2)
	cursor_tween.tween_callback(coin_button_press)
	cursor_tween.tween_interval(0.2)
	cursor_tween.tween_callback(coin_button_press)

func coin_button_press():
	coins += 1
	coins_in_this_round += 1
	coins_uncounted -= 1
	UI.get_node("CoinButton").text = "+1/" + str(coins_uncounted)
	UI.get_node("Coins").text = "$" + str(coins)
	if coins_uncounted == 0:
		UI.get_node("CoinButton").visible = false
		if coin_tween:
			coin_tween.stop()
		coin_tween = null

func _on_trash_mouse_over_change(mouse_over: bool):
	mouse_over_trash = mouse_over
