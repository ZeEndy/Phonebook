extends "res://Scripts/WAD/WadSprite.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed=4
var direction = 0
var friction=0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index=1
	modulate = Color.white.linear_interpolate(Color.yellow, randf())
	material.set("blend_mode",BLEND_MODE_ADD)
	frame=speed
	global_position+=Vector2(speed*60,0).rotated(deg2rad(direction))*delta
	speed=clamp(speed,0,10)
	speed-=friction*60*delta
	if speed<1:
		queue_free()
