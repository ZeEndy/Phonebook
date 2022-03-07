extends AudioStreamPlayer2D

var current_pitch=1
var affected_time=true

func _process(_delta):
	
	if affected_time:
		pitch_scale=current_pitch*Engine.time_scale
	if !playing or stream==null:
		get_parent().remove_child(self)
		queue_free()
