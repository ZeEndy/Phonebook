extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed=2
var direction = 0
var friction=0.1


#func _ready():
#	get_node("AnimatedSprite").speed_scale=0
#	if speed==0:
#		var body=get_node("AnimatedSprite").get_path()
#		get_parent().get_node(get_parent().my_surface).add_to_surface(body,global_position,global_rotation)
#		queue_free()
#
#func _process(delta):
##	material.set("blend_mode",BLEND_MODE_ADD)
#	global_rotation=direction
#	var c=move_and_collide(Vector2(speed*60,0).rotated(direction)*delta)
#	speed-=friction*60*delta
#	speed=clamp(speed,0,10)
#	if speed==0 or c:
#		var body=get_node("AnimatedSprite").get_path()
#		if "my_surface" in get_parent():
#			get_parent().get_node(get_parent().my_surface).add_to_surface(body,global_position,global_rotation)
#		queue_free()
