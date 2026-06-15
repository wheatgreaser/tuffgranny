extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_wall(direction: Vector2) -> Node3D:
	match direction:
		Vector2(1, 0):   return $StaticBody3D5  # +X wall
		Vector2(-1, 0):  return $StaticBody3D4  # -X wall
		Vector2(0, 1):   return $StaticBody3D2  # +Z wall
		Vector2(0, -1):  return $StaticBody3D3  # -Z wall
	return null
