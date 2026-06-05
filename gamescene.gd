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
				var door_instance = door.instantiate()
				room_instance.position = Vector3(i, 0, j)
				door_instance.position = Vector3(i, 0, j)
				add_child(room_instance)
				add_child(door_instance)
				map1[i][j] = 1
				k1 += 1
			else:
				map1[i][j] = 0
			
	print(path1)
	print(map1)
	
	for i in range(3):
		for j in range(3):
			if (map2[i][j] == path2[k2] and k2 < path2.size()):
				map2[i][j] = 1
				k2 += 1
			else:
				map2[i][j] = 0
			
	print(path2)
	print(map2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
