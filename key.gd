extends Node3D
@export var key_id = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.keys_owned[key_id] = true
		print(body.keys_owned)
		queue_free()
	else:
		pass
