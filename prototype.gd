extends Node2D
var k = 1
var paths = []
func mapper(grid):
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
	var map1 = []
	mapper(map1)
	pathgen(Vector2(0,0), [], {}, map1)
	print(paths)

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
