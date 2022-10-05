extends AudioStreamPlayer2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var current_pitch = 1
var gear_pitch = 1


func _process(_delta):
	pitch_scale=(current_pitch*gear_pitch)*Engine.time_scale
