extends AudioStreamPlayer2D

var current_pitch=1
var affected_time=true

func _ready():
	play()
#	finished().connect(self, "finished")
func _process(_delta):
	if affected_time:
		pitch_scale=current_pitch*Engine.time_scale
#	if !is_playing():
#		queue_free()
#	if !stream:
#		stop()
#		queue_free()
#func finished():
#	stop()
#	queue_free()
func _enter_tree():
	print(global_position)
func _exit_tree():
	print("WHAT")
