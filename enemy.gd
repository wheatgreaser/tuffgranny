extends CharacterBody3D


const SPEED = 1.0
const JUMP_VELOCITY = 4.5

@onready var nav = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	
	
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * SPEED
	var direction = (next_location - current_location).normalized()
	velocity = velocity.move_toward(new_velocity, 0.25)
	
	if direction.length() > 0.001:
		look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)
	move_and_slide()

func target_position(target):
	nav.target_position = target


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass
