extends Node3D

var paths = []
var rng = RandomNumberGenerator.new()
@export var map1 = []
@export var map2 = []

var room = preload("res://room.tscn")
var door = preload("res://door.tscn")



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
	rng.randomize()
	var door_pos = []
	mapper(map1)
	mapper(map2)
	pathgen(Vector2(0,0), [], {}, map1)
	var randnum1 = rng.randi_range(0, paths.size() - 1)
	var randnum2 = rng.randi_range(0, paths.size() - 1)
	var path1 = paths[randnum1]
	var path2 = paths[randnum2]
	var k1 = 0
	var k2 = 0

	for i in range(3):
		for j in range(3):
			if (map1[i][j] == path1[k1] and k1 < path1.size()):
				var room_instance = room.instantiate()
				
				room_instance.position = Vector3(i* 5, 0, j*5)
				room_instance.scale = Vector3(5,5,5)
				add_child(room_instance)
				
				map1[i][j] = 1
				door_pos.append(Vector3(i,0,j))
				k1 += 1
			else:
				map1[i][j] = 0
				
	for dpos in range(door_pos.size()-1):
		var door_instance = door.instantiate()
		door_instance.position = Vector3(((door_pos[dpos].x + door_pos[dpos+1].x)/2)*5, 0, ((door_pos[dpos].z+ door_pos[dpos+1].z)/2)*5)
		door_instance.scale = Vector3(5,5,5)
		add_child(door_instance)
		
						
	for i in range(3):
		for j in range(3):
			if (map2[i][j] == path2[k2] and k2 < path1.size()):
				var room_instance = room.instantiate()
				
				room_instance.position = Vector3(i* 5, 20, j*5)
				room_instance.scale = Vector3(5,5,5)
				add_child(room_instance)
				
				map2[i][j] = 1
				door_pos.append(Vector3(i,20,j))
				k2 += 1
			else:
				map2[i][j] = 0



