extends Control


func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://gamescene.tscn")

	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://gamescene.tscn")
