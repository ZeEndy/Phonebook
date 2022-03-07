extends "res://Scripts/WAD/WadSprite.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed =60
# Called when the node enters the scene tree for the first time.
func _ready():
	centered=false


func _process(delta):
	if visible==true:
		speed=60*scale.y
		global_position.y=get_viewport().size.y/3-(frames.get_frame(animation,frame).get_height()*scale.y)
		global_position.x-=speed*delta
		if global_position.x< -200:
			queue_free()
