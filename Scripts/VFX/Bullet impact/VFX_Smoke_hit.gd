extends "res://Scripts/WAD/WadSprite.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed=0.5
var direction = 0
var friction=0.01


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index=1
	speed_scale=0.3
#	material.set("blend_mode",BLEND_MODE_ADD)
	global_rotation= direction-deg_to_rad(180)
	global_position+=Vector2(speed*60,0).rotated(direction)*delta
	speed-=friction*60*delta
	speed=clamp(speed,0,10)
	if frame==frames.get_frame_count(animation)-1:
		queue_free()
