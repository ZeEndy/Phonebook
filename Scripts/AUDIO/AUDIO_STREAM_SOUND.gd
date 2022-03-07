extends AudioStreamPlayer

var current_pitch=1
var affected_time=true

func _ready():
	var _finish= connect("finished", self, "finished")
func _process(_delta):
	if affected_time:
		pitch_scale=current_pitch*Engine.time_scale
	if !is_playing():
		stop()
	if !stream:
		stop()
		queue_free()
func finished():
	stop()
	queue_free()
