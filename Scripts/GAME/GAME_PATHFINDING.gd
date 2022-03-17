extends TileMap

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color.white

# The Tilemap node doesn't have clear bounds so we're defining the map's limits here.
export(Vector2) var map_size = Vector2.ONE * 16

# The path start and end variables use setter methods.
# You can find them at the bottom of the script.
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []

# You can only create an AStar node from code, not from the Scene tab.
onready var astar_node = AStar2D.new()
# get_used_cells_by_id is a method from the TileMap node.
# Here the id 0 corresponds to the grey tile, the obstacles.
onready var obstacles = get_used_cells_by_id(0)
onready var _half_cell_size = cell_size / 2


export var nav_map_up_to_date=true

func _ready():
	tile_set.clear()
	tile_set.create_tile(0)
	tile_set.create_tile(1)
	yield(get_tree().create_timer(0.2), "timeout")
	nav_map_up_to_date=false

func _process(_delta):
	if nav_map_up_to_date==false:
		update_navigation_map()
		var walkable_cells_list = astar_add_walkable_cells(get_used_cells_by_id(0))
		astar_connect_walkable_cells_mix(walkable_cells_list)
		update()
		
		nav_map_up_to_date=true
	if Input.is_action_just_pressed("ui_up"):
		nav_map_up_to_date=false


#func _draw():
#	if not _point_path:
#		return
#	var point_start = _point_path[0]
#	var point_end = _point_path[len(_point_path) - 1]
#
##	set_cell(point_start.x, point_start.y, 1)
##	set_cell(point_end.x, point_end.y, 2)
#
##	for i in astar_node.get_points():
##		var pos=map_to_world(astar_node.get_point_position(i))
##		draw_rect(Rect2(pos,Vector2(2,2)),Color(1,1,1))
#
#	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size
#	for index in range(1, len(_point_path)):
#		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
#		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
##		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
#		last_point = current_point


# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles.
func astar_add_walkable_cells(obstacle_list = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacle_list:
				continue

			points_array.append(point)
			# The AStar class references points with indices.
			# Using a function to calculate the index from a point's coordinates
			# ensures we always get the same index with the same input point.
			var point_index = calculate_point_index(point)
			# AStar works for both 2d and 3d, so we have to convert the point
			# coordinates from and to Vector3s.
			astar_node.add_point(point_index, Vector2(point.x, point.y))
	return points_array

func astar_connect_walkable_cells_mix(points_array):
	for point in points_array:
		var pointIndex = calculate_point_index(point)

		for offsetX in range(-1, 2):
			for offsetY in range(-1, 2):

				var neighbourOffset = Vector2(offsetX, offsetY)
				if neighbourOffset == Vector2.ZERO:
					continue

				var neighbourPoint = point + neighbourOffset
				if is_outside_map_bounds(neighbourPoint):
					continue

				var neighbourIndex = calculate_point_index(neighbourPoint)
				if not astar_node.has_point(neighbourIndex):
					continue

				var isDiagonalNeighbour = neighbourOffset.abs() == Vector2.ONE
				if isDiagonalNeighbour:

					var adjacentHorizontalNeighbourIndex = calculate_point_index(point + Vector2(offsetX, 0))
					if not astar_node.has_point(adjacentHorizontalNeighbourIndex):
						continue

					var adjacentVerticalNeighbourIndex = calculate_point_index(point + Vector2(0, offsetY))
					if not astar_node.has_point(adjacentVerticalNeighbourIndex):
						continue

				astar_node.connect_points(pointIndex, neighbourIndex, true)


# Once you added all points to the AStar node, you've got to connect them.
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like.
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce.
		# We connect the current point with it.
		var points_relative = PoolVector2Array([
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.DOWN,
			point + Vector2.UP,
		])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A.
			# If you set this value to false, it becomes a one-way path.
			# As we loop through all points we can set it to false.
			astar_node.connect_points(point_index, point_relative_index, false)


# This is a variation of the method above.
# It connects cells horizontally, vertically AND diagonally.
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)
				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)


func calculate_point_index(point):
	return point.x + map_size.x * point.y


func clear_previous_path_drawing():
	if not _point_path:
		return
	var _point_start = _point_path[0]
	var _point_end = _point_path[len(_point_path) - 1]
#	set_cell(point_start.x, point_start.y, -1)
#	set_cell(point_end.x, point_end.y, -1)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func get_astar_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + _half_cell_size
		path_world.append(point_world)
	
#	for i in path_world.size()-1:
#		if path_world.size()-2>0:
#			var x = 0
#			while x!=path_world.size()-i-1:
#				var space = get_world_2d().direct_space_state
#				var check_point=space.intersect_ray(path_world[i],path_world[i+x],[],collision_layer)
#				if check_point.size()>0:
#					print(i+x)
#					path_world.remove(i+x)
#				x+=1
#			break
	return path_world


func _recalculate_path():
	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and
	# end points' indices as input.
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point.
	update()
	pass

# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

#	set_cell(path_start_position.x, path_start_position.y, 0)
#	set_cell(value.x, value.y, 1)
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

#	set_cell(path_start_position.x, path_start_position.y, 0)
#	set_cell(value.x, value.y, 2)
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()



func update_navigation_map():
	var time_start = OS.get_ticks_msec()
	var shape = RectangleShape2D.new()
	shape.extents=(get_cell_size()*0.75)
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(shape)
	query.collision_layer=collision_layer
	clear()
	for point_x in map_size.x:
		for point_y in map_size.y:
			var space = get_world_2d().direct_space_state
			var point_position=map_to_world(Vector2(point_x,point_y))
			query.set_transform(Transform2D(0, point_position+(cell_size*0.75 )))
			var check_point=space.intersect_shape(query,1)
			
			if check_point!=[]:
				set_cell(point_x,point_y,0)
				
			else:
				set_cell(point_x,point_y,1)
	print("calculation time: "+str(OS.get_ticks_msec()-time_start)+"ms")
	


#
#
## Start and end are both in world coordinates
#func get_new_path(start: Vector2, end: Vector2) -> Array:
#
#	var start_tile = world_to_map(start)
#	var end_tile = world_to_map(end.round())
#
#	var start_id = get_id_for_point(start_tile)
#	var end_id = get_id_for_point(end_tile)
#
#	if not astar.has_point(start_id) or not astar.has_point(end_id):
#		return []
#
#	var path_map = astar.get_point_path(start_id, end_id)
#
#	var path_world = []
#	for point in path_map:
#		var point_world = map_to_world(point)+half_cell_size
#		path_world.append(point_world)
#
#	return path_world
