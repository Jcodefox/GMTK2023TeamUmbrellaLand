extends CharacterBody2D


const SPEED = 70.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_move: bool = true
@export var move_offscreen: bool = false
var is_on_screen: bool = false

func _physics_process(delta):
	if not $VisibleOnScreenNotifier2D.is_on_screen() and not move_offscreen:
		return
	if not can_move:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = -1
	if direction and is_on_floor():
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
