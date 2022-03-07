extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var shake=0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	shake-=delta*120
	shake=clamp(shake,0,1000)
	var ranged=shake*(delta*(Engine.get_frames_per_second()/30))
	offset=Vector2(rand_range(-ranged,ranged),rand_range(-ranged,ranged))
	smoothing_speed=6/Engine.time_scale
#	var position_pixel_locked=Vector2(round(global_position.x/2),round(global_position.y/2))
#	global_position=position_pixel_locked*2

