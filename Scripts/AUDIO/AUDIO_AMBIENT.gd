extends AudioStreamPlayer


var efx=""
var current_pitch=1.0
var affected_time=false
var stupid_check=false

# Called when the node enters the scene tree for the first time.
func _ready():
	await RenderingServer.frame_post_draw
	stupid_check=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if affected_time:
		pitch_scale=current_pitch*Engine.time_scale
	if efx=="slowmo":
		if Engine.time_scale==1.0 && stupid_check==true:
			volume_db=lerp(volume_db,-80.0,delta*0.25)
			if volume_db< -60.0:
				queue_free()
