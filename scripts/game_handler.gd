extends Node2D

var is_clicked: bool = false
var offset: Vector2 = Vector2.ZERO
var handled_enemy: PhysicsBody2D = null
var mouse_over_trash: bool = false
var enemy_tween: Tween = null
var coin_tween: Tween = null

var coins: int = 0
var coins_uncounted: int = 0

func _ready():
	UI.get_node("Trash").mouse_entered.connect(_on_trash_mouse_over_change.bind(true))
	UI.get_node("Trash").mouse_exited.connect(_on_trash_mouse_over_change.bind(false))
	UI.get_node("CoinButton").pressed.connect(coin_button_press)

func enemy_stomped(enemy: PhysicsBody2D):
	enemy.scale.y = 0.75
	enemy.position.y += 2
	enemy.z_index = 10
	handled_enemy = enemy
	enemy.input_event.connect(enemy_input_event)
	enemy.process_mode = Node.PROCESS_MODE_ALWAYS
	enemy.can_move = false
	UI.get_node("Trash").visible = true
	UI.get_node("TimeBar").visible = true
	UI.get_node("TimeBar").value = 0
	get_tree().paused = true
	enemy_tween = get_tree().create_tween()
	$ColorRect.color.a = 0.75
	enemy_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	enemy_tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 3)
	enemy_tween.parallel()
	enemy_tween.tween_property(UI.get_node("TimeBar"), "value", 100, 3)
	enemy_tween.tween_callback(finish_tween)

func finish_tween():
	enemy_tween = null
	UI.get_node("Trash").visible = false
	UI.get_node("TimeBar").visible = false
	if handled_enemy != null:
		handled_enemy.process_mode = PROCESS_MODE_INHERIT
		$ColorRect.color = Color(0, 0, 0, 0.9)
		UI.get_node("Lose").visible = true
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
		enemy_tween.stop()
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

func coin_collected():
	coins_uncounted += 1
	UI.get_node("CoinButton").visible = true
	if coin_tween != null:
		coin_tween.stop()
		coin_tween = null
	coin_tween = get_tree().create_tween()
	UI.get_node("CoinButton").modulate = Color.WHITE
	coin_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	coin_tween.tween_property(UI.get_node("CoinButton"), "modulate", Color(1, 1, 1, 0), 3)
	coin_tween.tween_callback(func():
		UI.get_node("Lose").visible = true
		UI.get_node("Trash").visible = false
		UI.get_node("TimeBar").visible = false
		$ColorRect.color = Color(0, 0, 0, 0.9)
		if handled_enemy != null:
			handled_enemy.process_mode = PROCESS_MODE_INHERIT
			handled_enemy.z_index = 0
			enemy_tween.stop()
			enemy_tween = null
	)

func coin_button_press():
	coins += 1
	coins_uncounted -= 1
	UI.get_node("Coins").text = "$" + str(coins)
	if coins_uncounted == 0:
		UI.get_node("CoinButton").visible = false
	coin_tween.stop()
	coin_tween = null

func _on_trash_mouse_over_change(mouse_over: bool):
	mouse_over_trash = mouse_over
