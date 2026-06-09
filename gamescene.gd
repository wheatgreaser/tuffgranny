extends Node3D

var paths = []
var rng = RandomNumberGenerator.new()
@export var map1 = []
@export var map2 = []

var room = preload("res://room.tscn")
var door = preload("res://door.tscn")
var key = preload("res://key.tscn")
var portal = preload("res://portal.tscn")
@onready var player = $Player

func mapper(grid):
	var k = 1
	for i in range(3):
		grid.append([])
		for j in range(3):
			grid[i].append(k)
			k+=1

func pathgen(pos, path, visited, map):
	var x = pos.x
	var y = pos.y
	path.append(map[y][x])
	visited[pos] = true
	
	
	if map[y][x] == 9:
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
			if (next.x >= 0 and next.x < 3 and next.y >= 0 and next.y < 3 and not visited.has(next)):
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
	var key_door_dict = {}
	var room_node_lookup2 = {} 
	var room_node_lookup1 = {}
	mapper(map1)
	mapper(map2)
	pathgen(Vector2(0,0), [], {}, map1)
	var randnum1 = rng.randi_range(0, paths.size() - 1)
	var path1 = paths[randnum1]
	
	while (path1.size() != path2.size()):
		var randnum2 = rng.randi_range(0, paths.size() - 1)
		path2 = paths[randnum2]
		
	

	for i in range(3):
		for j in range(3):
			if map1[i][j] in path1:
				rng.randomize()
				var colorrandr = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandg = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandb = rng.randi_range(0, 255)
				var room_instance = room.instantiate()
				var mesh = room_instance.get_node("Floor/floorbody")
				var mat = StandardMaterial3D.new()
	
				mat.albedo_color = Color8(colorrandr, colorrandg, colorrandb)
				mesh.material_override = mat
				var room_id = map1[i][j]
				room_instance.position = Vector3(i* 5, 0, j*5)
				var portal_instance = portal.instantiate()
				portal_instance.position = Vector3(i* 5, -2, j*5)
				portal_instance.player_camera = $Player/Camera3D
				
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
		door_instance.position = Vector3(
		(a.x + b.x) * 2.5,
		-2,
		(a.z + b.z) * 2.5
		)
		
		door_instance.scale = Vector3(5,5,5)
		add_child(door_instance)
		doors1.append(door_instance)
						
	for i in range(3):
		for j in range(3):
			if map2[i][j] in path2:
				rng.randomize()
				var colorrandr = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandg = rng.randi_range(0, 255)
				rng.randomize()
				var colorrandb = rng.randi_range(0, 255)
				var room_id = map2[i][j]
				var room_instance = room.instantiate()
				room_instance.position = Vector3(i* 5, 20, j*5)
				room_instance.scale = Vector3(5,5,5)
				room_node_lookup2[room_id] = room_instance
				var mesh = room_instance.get_node("Floor/floorbody")
				var mat = StandardMaterial3D.new()
				mat.albedo_color = Color8(colorrandr, colorrandg, colorrandb)
				mesh.material_override = mat
				var portal_instance = portal.instantiate()
				portal_instance.player_camera = $Player/Camera3D
				portal_instance.position = Vector3(i* 5, 18, j*5)
				portalsB.append(portal_instance)
				add_child(portal_instance)
		
				room_nodes2.append(room_instance)
				room_lookup2[room_id] = Vector3(i, 20, j)
				add_child(room_instance)
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

	for i in range(portalsA.size()):
		portalsA[i].exit_portal = portalsB[i]
		portalsB[i].exit_portal = portalsA[i]
		portalsA[i].activate()
		portalsB[i].activate()
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
	
