extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var top_position=0
var bottom_position=0
@onready var top=get_node("top")
@onready var bottom=get_node("bottom")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !top.is_colliding():
		top_position=top.cast_to.x
	else:
		top_position=(top.get_collision_point()-top.global_position).length()
	if !bottom.is_colliding():
		bottom_position=bottom.cast_to.x
	else:
		bottom_position=(bottom.get_collision_point()-bottom.global_position).length()
	get_node("Polygon2D").polygon=PackedVector2Array([
		Vector2(0.000004,1),
		Vector2(-0.000002,0),
		Vector2(top_position,-1*(clamp(top_position-top.cast_to.x,0,top.cast_to.x)/top.cast_to.x)),
		Vector2(bottom_position,1+(1*(clamp(bottom_position-bottom.cast_to.x,0,bottom.cast_to.x)/bottom.cast_to.x)))])
