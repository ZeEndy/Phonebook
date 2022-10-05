extends "res://Scripts/WAD/WadSprite.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed=0.5
var direction = 0
var friction=5
var start=true

func _ready():
	self_modulate.a=0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index= -4
	speed_scale=0
#	material.set("blend_mode",BLEND_MODE_ADD)
	self_modulate.a+=60*delta
	self_modulate.a=clamp(self_modulate.a,0,1)
	global_rotation= direction-deg_to_rad(180)
	global_position+=Vector2(speed*60,0).rotated(direction)*delta
	speed-=friction*60*delta
	speed=clamp(speed,0,10)
	if speed==0:
		if !(get_parent() is SubViewport):
			get_parent().get_node(get_parent().my_surface).add_to_surface(self.get_path(),global_position,global_rotation)
