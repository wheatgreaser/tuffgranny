extends Node3D

var paths = []
var rng = RandomNumberGenerator.new()
@export var map1 = []
@export var map2 = []
@onready var target=$Player
var room = preload("res://room.tscn")
var door = preload("res://door.tscn")
var key = preload("res://key.tscn")
var portal = preload("res://portal.tscn")
var flag = preload("res://endgoal.tscn")
var dimension_a_order = []
var dimension_b_order = []
var dim = 3
const room_spacing := 5.0
const room_scale := Vector3(5, 5, 5)
const portal_scale := Vector3(0.7, 0.7, 0.7)

const room_meshes := [
	"StaticBody3D2/MeshInstance3D2",
	"StaticBody3D3/MeshInstance3D6",
	"StaticBody3D4/MeshInstance3D5",
	"StaticBody3D5/MeshInstance3D4",
	"NavigationRegion3D/Floor/floorbody"
]
@onready var player = $Player
func random_color() -> Color:
	return Color8(
		rng.randi_range(0, 255),
		rng.randi_range(0, 255),
		rng.randi_range(0, 255)
	)
func apply_room_color(room_instance: Node3D, color: Color) -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color

	for mesh_path in room_meshes:
		var mesh = room_instance.get_node(mesh_path)
		mesh.material_override = mat.duplicate()
func build_dimension(
	path: Array,
	grid: Array,
	y_offset: float,
	portal_y_offset: float
) -> Dictionary:

	var data = {
		"room_lookup": {},
		"room_nodes": {},
		"room_colors": {},
		"portal_lookup": {},
		"keys": [],
		"doors": []
	}

	for i in range(dim):
		for j in range(dim):

			var room_id = grid[i][j]

			if room_id not in path:
				grid[i][j] = 0
				continue

			var color = random_color()

			var room_instance = room.instantiate()
			room_instance.position = Vector3(
				i * room_spacing,
				y_offset,
				j * room_spacing
			)
			room_instance.scale = room_scale

			apply_room_color(room_instance, color)

			add_child(room_instance)

			data.room_lookup[room_id] = Vector3(i, y_offset, j)
			data.room_nodes[room_id] = room_instance
			data.room_colors[room_id] = color

			var portal_instance = portal.instantiate()
			portal_instance.position = Vector3(
				i * room_spacing,
				portal_y_offset,
				j * room_spacing
			)
			portal_instance.player_camera = $Player/Camera3D
			portal_instance.scale = portal_scale

			add_child(portal_instance)

			data.portal_lookup[room_id] = portal_instance

			grid[i][j] = 1

	for i in range(path.size() - 1):

		var a = data.room_lookup[path[i]]
		var b = data.room_lookup[path[i + 1]]

		var dir = Vector2(b.x - a.x, b.z - a.z)

		var room_a = data.room_nodes[path[i]]
		var room_b = data.room_nodes[path[i + 1]]

		var door_instance = door.instantiate()

		door_instance.lock_id = path[i + 1]

		door_instance.wall_node_a = room_a.get_wall(dir)
		door_instance.wall_node_b = room_b.get_wall(-dir)

		if dir == Vector2(1, 0):
			door_instance.door_rot = Vector3(0, deg_to_rad(90), 0)
		elif dir == Vector2(-1, 0):
			door_instance.door_rot = Vector3(0, deg_to_rad(-90), 0)
		elif dir == Vector2(0, 1):
			door_instance.door_rot = Vector3(0, deg_to_rad(180), 0)
		else:
			door_instance.door_rot = Vector3.ZERO

		door_instance.position = Vector3(
			(a.x + b.x) * room_spacing / 2.0,
			portal_y_offset,
			(a.z + b.z) * room_spacing / 2.0
		)

		door_instance.scale = room_scale

		add_child(door_instance)

		data.doors.append(door_instance)

	return data
func mapper(grid):
	var k = 1
	for i in range(dim):
		grid.append([])
		for j in range(dim):
			grid[i].append(k)
			k+=1

func pathgen(pos, path, visited, map):
	var x = pos.x
	var y = pos.y
	path.append(map[y][x])
	visited[pos] = true
	
	
	if map[y][x] == (dim*dim):
		paths.append(path.duplicate())
	else:
		var directions = [
			Vector2(0, 1),
			Vector2(1, 0),
			Vector2(-1, 0),
			Vector2(0, -1)
		]
		for dir in directions:
			var next = pos + dir
			if (next.x >= 0 and next.x < dim and next.y >= 0 and next.y < dim and not visited.has(next)):
				pathgen(next, path, visited, map)
				
	path.pop_back()
	visited.erase(pos)
					
	
func _ready():
	player.position = Vector3(2,0,2)
	rng.randomize()
	var door_pos1 = []
	var door_pos2 = []
	var room_nodes1 = []
	var room_nodes2 = []
	var portalsA = []
	var portalsB = []
	var doors1 = []
	var doors2 = []
	var path2 = []
	var key_in_A = []
	var key_in_B = []
	var room_lookup1 = {}
	var room_lookup2 = {}
	var room_colors_A = {}
	var room_colors_B = {}
	var room_node_lookup2 = {} 
	var room_node_lookup1 = {}
	var portal_lookup_A = {}
	var portal_lookup_B = {}
	var portal_map = {}
	
	mapper(map1)
	mapper(map2)
	paths.clear()
	pathgen(Vector2(0,0), [], {}, map1)
	var all_paths = paths.duplicate(true)  # deep copy
	var randnum1 = rng.randi_range(0, paths.size() - 1)
	var path1 = all_paths[randnum1].duplicate()

	while path2.size() != path1.size():
		var randnum2 = rng.randi_range(0, all_paths.size() - 1)
		path2 = all_paths[randnum2].duplicate()
	dimension_a_order = path1.duplicate()
	dimension_b_order = path2.duplicate()
	for i in range(path1.size()):
		portal_map[path1[i]] = path2[i]
	for i in range(dim):
		for j in range(dim):
			if map1[i][j] in path1:
				rng.randomize()
				var colorrandr = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandg = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandb = rng.randi_range(0, 255)
				var room_instance = room.instantiate()
				var mesh1 = room_instance.get_node("StaticBody3D2/MeshInstance3D2")
				var mesh2 = room_instance.get_node("StaticBody3D3/MeshInstance3D6")
				var mesh3 = room_instance.get_node("StaticBody3D4/MeshInstance3D5")
				var mesh4 = room_instance.get_node("StaticBody3D5/MeshInstance3D4")
				var mesh5 = room_instance.get_node("NavigationRegion3D/Floor/floorbody")
				var mat = StandardMaterial3D.new()
	
				mat.albedo_color = Color8(colorrandr, colorrandg, colorrandb)
				mesh1.material_override = mat.duplicate()
				mesh2.material_override = mat.duplicate()
				mesh3.material_override = mat.duplicate()
				mesh4.material_override = mat.duplicate()
				mesh5.material_override = mat.duplicate()
				var room_id = map1[i][j]
				room_instance.position = Vector3(i* 5, 0, j*5)
				var portal_instance = portal.instantiate()
				portal_instance.position = Vector3(i * 5, -2, j * 5)
				portal_instance.player_camera = $Player/Camera3D
				portal_instance.scale = Vector3(0.7, 0.7, 0.7)
				portal_lookup_A[room_id] = portal_instance
				add_child(portal_instance)
				portalsA.append(portal_instance)
				room_lookup1[room_id] = Vector3(i, 0, j)
				room_nodes1.append(room_instance)
				room_instance.scale = Vector3(5,5,5)
				room_node_lookup1[room_id] = room_instance
				add_child(room_instance)
				room_colors_A[room_id] = Color8(colorrandr, colorrandg, colorrandb)
				map1[i][j] = 1
				door_pos1.append(Vector3(i,0,j))
			else:
				map1[i][j] = 0
	for i in range(1, path1.size()): 
		var room_id = path1[i]
		var pos = room_lookup1[room_id]
		var key_instance = key.instantiate()
		key_instance.position = Vector3(pos.x * 5 + 2, -2, pos.z * 5 + 2)
		key_instance.scale = Vector3(0.2, 0.2, 0.2)
		key_in_A.append(key_instance)
		add_child(key_instance)
	for i in range(path1.size() - 1):
		var a = room_lookup1[path1[i]]
		var b = room_lookup1[path1[i + 1]]
		var dir = Vector2(b.x - a.x, b.z - a.z)
		var room_a_node = room_node_lookup1[path1[i]]
		var room_b_node = room_node_lookup1[path1[i + 1]]
		

		
		var door_instance = door.instantiate()
		door_instance.lock_id = path1[i + 1]
		door_instance.wall_node_a = room_a_node.get_wall(dir)
		door_instance.wall_node_b = room_b_node.get_wall(-dir) 
		if dir == Vector2(1, 0):    
			door_instance.door_rot = Vector3(0, deg_to_rad(90), 0)
		elif dir == Vector2(-1, 0):  
			door_instance.door_rot = Vector3(0, deg_to_rad(-90), 0)
		elif dir == Vector2(0, 1):    
			door_instance.door_rot = Vector3(0, deg_to_rad(180), 0)
		else:                        
			door_instance.door_rot = Vector3.ZERO
		door_instance.position = Vector3(
		(a.x + b.x) * 2.5,
		-2,
		(a.z + b.z) * 2.5
		)

		door_instance.scale = Vector3(5,5,5)
		add_child(door_instance)
		doors1.append(door_instance)
		
						
	for i in range(dim):
		for j in range(dim):
			if map2[i][j] in path2:
				rng.randomize()
				var colorrandr = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandg = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandb = rng.randi_range(0, 255)
				var room_id = map2[i][j]
				var room_instance = room.instantiate()
				var mesh1 = room_instance.get_node("StaticBody3D2/MeshInstance3D2")
				var mesh2 = room_instance.get_node("StaticBody3D3/MeshInstance3D6")
				var mesh3 = room_instance.get_node("StaticBody3D4/MeshInstance3D5")
				var mesh4 = room_instance.get_node("StaticBody3D5/MeshInstance3D4")
				var mesh5 = room_instance.get_node("NavigationRegion3D/Floor/floorbody")
				room_instance.position = Vector3(i* 5, 20, j*5)
				room_instance.scale = Vector3(5,5,5)
				room_node_lookup2[room_id] = room_instance
				
				var mat = StandardMaterial3D.new()
				mat.albedo_color = Color8(colorrandr, colorrandg, colorrandb)
				
				mesh1.material_override = mat.duplicate()
				mesh2.material_override = mat.duplicate()
				mesh3.material_override = mat.duplicate()
				mesh4.material_override = mat.duplicate()
				mesh5.material_override = mat.duplicate()
				
				room_nodes2.append(room_instance)
				room_lookup2[room_id] = Vector3(i, 20, j)
				add_child(room_instance)

				var portal_instance = portal.instantiate()
				portal_instance.position = Vector3(i * 5, 18, j * 5)
				portal_instance.player_camera = $Player/Camera3D
				portal_instance.scale = Vector3(0.7, 0.7, 0.7)
				add_child(portal_instance)
				portalsB.append(portal_instance)
				portal_lookup_B[room_id] = portal_instance
				map2[i][j] = 1
				door_pos2.append(Vector3(i,20,j))
				room_colors_B[room_id] = Color8(colorrandr, colorrandg, colorrandb)
				
				
			else:
				map2[i][j] = 0
	for i in range(0, path2.size()-1): 
		var room_id = path2[i]
		var pos = room_lookup2[room_id]
		var key_instance = key.instantiate()
		key_instance.position = Vector3(pos.x * 5 + 2, 17.7, pos.z * 5 + 2)
		key_instance.scale = Vector3(0.2, 0.2, 0.2)
		key_in_B.append(key_instance)
		add_child(key_instance)
		
	for i in range(path2.size() - 1):
		var a = room_lookup2[path2[i]]
		var b = room_lookup2[path2[i + 1]]
		

		var door_instance = door.instantiate()
		door_instance.lock_id = path2[i + 1]
		door_instance.position = Vector3(
			(a.x + b.x) * 2.5,
			18,
			(a.z + b.z) * 2.5
		)
		door_instance.scale = Vector3(5,5,5)	
		var dir = Vector2(b.x - a.x, b.z - a.z)
		var room_a_node = room_node_lookup2[path2[i]]
		var room_b_node = room_node_lookup2[path2[i + 1]]
		door_instance.wall_node_a = room_a_node.get_wall(dir)
		door_instance.wall_node_b = room_b_node.get_wall(-dir)

		add_child(door_instance)
		doors2.append(door_instance)

	for i in range(path1.size()):  
		var pa = portal_lookup_A[path1[i]]
		var pb = portal_lookup_B[path2[i]]
		pa.exit_portal = pb
		pb.exit_portal = pa
		pa.activate()
		pb.activate()
		
	print(room_colors_A)
	for i in range(key_in_B.size()):
		key_in_B[i].key_id = path1[i + 1]
		var mesh = key_in_B[i].get_node("keyobj/keymesh")
		var mat = StandardMaterial3D.new()
		mat.albedo_color = room_colors_A[path1[i+1]]
		mesh.material_override = mat
	
	for i in range(key_in_A.size()):
		key_in_A[i].key_id = path2[i + 1]
		var mesh = key_in_A[i].get_node("keyobj/keymesh")
		var mat = StandardMaterial3D.new()
		mat.albedo_color = room_colors_B[path2[i+1]]
		mesh.material_override = mat
	
	var endgoal = flag.instantiate()
	endgoal.position = room_node_lookup2[path2[path2.size()-1]].position
	add_child(endgoal)
	for room_id in portal_map:
		print(room_id, " -> ", portal_map[room_id])
func _process(delta):
	
	var endgoal = $endgoal
	if endgoal:
		print(endgoal.global_position.distance_to(player.global_position))
	if endgoal and endgoal.global_position.distance_to(player.global_position) < 3:
		
		get_tree().change_scene_to_file("res://winscreen.tscn")
	get_tree().call_group("enemy", "target_position", target.global_transform.origin)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.global_position.distance_to(player.global_position) < 0.3:
			pass
