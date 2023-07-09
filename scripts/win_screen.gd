extends Control

func _on_replay_pressed():
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
