extends "res://Scripts/WAD/WadSprite.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed=30
var direction = 0
var friction=0.01
var start=true

func _ready():
	self_modulate.a=0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed_scale=1
	modulate = Color.orangered.linear_interpolate(Color.yellow, randf())
	z_index=1
	if start==true:
		self_modulate.a+=(60*delta)
		self_modulate.a=clamp(self_modulate.a,0,1)
		if self_modulate.a==1:
			start=false
	else:
		self_modulate.a-=(10*delta)
		self_modulate.a=clamp(self_modulate.a,0,1)
#	modulate= modulate.linear_interpolate(Color.gray,speed/30)
	
#	material.set("blend_mode",BLEND_MODE_ADD)
	global_rotation= direction-deg2rad(180)
	global_position+=Vector2(speed*60,0).rotated(direction)*delta
	speed-=friction*60*delta
	speed=clamp(speed,0,10)
	if frame==frames.get_frame_count(animation)-1:
		queue_free()
