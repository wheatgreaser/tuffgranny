extends Control

var game_scene = preload("res://gamescene.tscn")
func _input(event):
	if (event is InputEventKey and event.pressed) \
	or (event is InputEventMouseButton and event.pressed):

		var game = game_scene.instantiate()
		get_tree().root.add_child(game)

		queue_free()
