extends Node3D

@export var lock_id = 0
@export var door_rot : Vector3
var unlock = 0
var wall_node_a: StaticBody3D
var wall_node_b: StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.keys_owned.has(lock_id):
			if wall_node_a:
				wall_node_a.queue_free()
				
			if wall_node_b:
				wall_node_b.queue_free()
			
			$AudioStreamPlayer3D.play()
			await $AudioStreamPlayer3D.finished
			queue_free()
