extends WadSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed =60
# Called when the node enters the scene tree for the first time.



func _process(delta):
	if visible==true:
		frame=22-abs((global_position.x/ (get_viewport().size.x*0.01)) )
		global_position.x-=30*scale.y*delta
		global_position.y=get_viewport().size.y/3-(frames.get_frame(animation,frame).get_height()*scale.y-offset.y)

		z_index=scale.y*10
		if global_position.x< -200:
			queue_free()
	 
