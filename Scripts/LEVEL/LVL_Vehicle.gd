extends StaticBody2D



@export var in_level=true
@export var door_list=[]
#inside array example
#Sprite Path
#Detector Path
#Collision enabler
var unlocked=false
var level_lock=false

var frame_wait_play_sound=false


# Called when the node enters the scene tree for the first time.
func _ready():
	await RenderingServer.frame_post_draw
	frame_wait_play_sound=true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in door_list:
		var sprite=get_node(i[0])
		var detector=get_node(i[1])
		var collision=get_node_or_null(i[2])
#		if sprite.name!="Trunk" || level_lock==false:
		var cockfuck=detector.get_overlapping_bodies()
		if cockfuck.size()!=0:
			if sprite is Sprite2D:
				sprite.rotation=lerp_angle(sprite.rotation,1.39626*sprite.scale.y,15*delta)
			else:
				sprite.speed_scale=1
				
			if collision!=null: collision.disabled=true
		else:
			if sprite is Sprite2D:
				sprite.rotation=lerp_angle(sprite.rotation,0,15*delta)
			else:
				sprite.speed_scale=-1
				
			if collision!=null: collision.disabled=false


