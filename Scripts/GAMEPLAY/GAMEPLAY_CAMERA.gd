extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name game_camera


@onready var floor_below=get_node_or_null("Floor_Below")
@onready var rain=get_node_or_null("../Rain")

@export_node_path("SubViewportContainer") var show_below_target

var below_target=null

# Called when the node enters the scene tree for the first time.
func _ready():
	ignore_rotation=false
	if show_below_target!=null:
		below_target=get_node_or_null(show_below_target)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom=get_tree().get_nodes_in_group("Glob_Camera_pos")[0].zoom
	rotation=deg_to_rad(get_tree().get_nodes_in_group("Glob_Camera_pos")[0].rot)
	position_smoothing_enabled=false
	position_smoothing_speed=0
	global_position=global_position.lerp(get_tree().get_nodes_in_group("Glob_Camera_pos")[0].global_position,5*delta/Engine.time_scale)
	offset=get_tree().get_nodes_in_group("Glob_Camera_pos")[0].offset
	if floor_below!=null:
		floor_below.position=offset
		floor_below.scale=zoom
		
	if rain!=null:
		rain.texture_offset=rain.global_position-(((get_viewport_rect().size/rain.texture_scale)/2))
		rain.texture_scale=zoom*10
	
	if below_target!=null:
		below_target.get_children()[0].constantly_show=true
#		rain.texture_scale.x=zoom.x*10
#		rain.texture_scale.y=zoom.y*10
#	var position_pixel_locked=Vector2(round(global_position.x/2),round(global_position.y/2))
#	global_position=position_pixel_locked*2

