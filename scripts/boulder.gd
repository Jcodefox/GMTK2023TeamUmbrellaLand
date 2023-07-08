extends RigidBody2D

func _process(delta):
	if abs(linear_velocity.x) > 0:
		$AnimatedSprite2D.play("default")
	else:
		$AnimatedSprite2D.stop()
	$AnimatedSprite2D.global_rotation = 0
