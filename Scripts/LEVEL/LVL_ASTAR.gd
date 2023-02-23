@tool
extends TileMap

class_name ASGrid

@export var bake_grid=false
@export var map_size:=Vector2()
@export_flags_2d_physics var collision_layer
@export var baked_agrid=[]



@export var _loaded_grid_in_game=false

var astar_node = null




func _ready():
	if astar_node==null && !Engine.is_editor_hint():
		astar_node=AStarGrid2D.new()
		astar_node.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		astar_node.jumping_enabled=true
		astar_node.default_compute_heuristic=AStarGrid2D.HEURISTIC_OCTILE
		astar_node.size=Vector2i(map_size)/tile_set.tile_size
		print(astar_node.size)
		astar_node.cell_size=tile_set.tile_size
		print(astar_node.cell_size)
		astar_node.update()
	


func _process(delta):
	if Engine.is_editor_hint():
		if bake_grid==false:
			if get_used_cells(0)!=[]:
				clear()
		else:
			if get_used_cells(0)==[]:
				_bake_grid()
	else:
		if _loaded_grid_in_game==false:
			_load_baked_grid()

func _bake_grid():
#	var time_start = OS.get_ticks_msec()
	var shape = RectangleShape2D.new()
	shape.extents=(tile_set.tile_size*1.25)
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.collision_mask=collision_layer
	var space = get_world_2d().direct_space_state
	var tile_size=tile_set.tile_size.x
	for point_x in map_size.x/tile_size:
		for point_y in map_size.y/tile_size:
			query.transform=Transform2D(0, map_to_local(Vector2(point_x,point_y)) )
			if space.intersect_shape(query,1)!=[]:
				set_cell(0,Vector2i(point_x,point_y),0,Vector2i(0,0),0)
#	print("calculation time: "+str(OS.get_ticks_msec()-time_start)+"ms")


func _load_baked_grid():
	if astar_node!=null:
		for i in get_used_cells(0):
			astar_node.set_point_solid(i,true)
		_loaded_grid_in_game=true
#

func _get_path(from,to): 
	var fuck = Array(astar_node.get_point_path(from/tile_set.tile_size.x,to/tile_set.tile_size.x))
#	print(fuck)
	return fuck

