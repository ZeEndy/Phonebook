extends Node2D


#@export_placeholder(Noise) var noise
@export var noise : Noise

@export_range(0,1) var shake = 0
@export_range(1,99) var intensity=1

var time = 0

@export var max_x = 100
@export var max_y = 100
@export var max_r = 10.0
@export var time_scale = 150
var offset = Vector2(0,0)
var zoom = Vector2(1,1)
var added_zoom=1
var rot = 0

var follow_speed=0.044444

var show_case=false

@onready var rain=get_node_or_null("Rain")

var target=null





@export_range(0,1) var timer = 0.0

func add_shake(shake_in,adative):
	if adative==false: shake = clamp(shake_in,0,1)
	else: shake = clamp(shake+shake_in,0,1)

func _process(delta):
	if show_case==false:
		if target!=null:
			global_position=target.global_position
		zoom=Vector2(lerp(zoom.x,3.8*added_zoom,20*delta/Engine.time_scale),lerp(zoom.y,3.8*added_zoom,20*delta/Engine.time_scale))
	else:
		zoom=Vector2(6,6)
	
	if rain!=null:
		get_node("Rain").get_camera_3d().global_transform.origin.x=lerp(get_node("Rain").get_camera_3d().global_transform.origin.x,((global_position)*zoom*follow_speed).x,clamp(6.6666*delta,0,1))+(offset.x*0.0004*follow_speed)
#		get_node("Rain").get_camera().global_transform.origin.z=lerp(get_node("Rain").get_camera().global_transform.origin.z,-((global_position)*zoom*follow_speed).y,6.6666*delta)+(offset.y*0.0004*follow_speed)
		get_node("Rain").size=get_viewport().size
	time += delta
	var shaking = pow(shake,2)
	
#	var noise_inst=noise.new()
#	var breath_noise_inst=breathing_noise.new()
	offset.x = (noise.get_noise_3d(time * time_scale,0,0) * max_x * shaking)
	offset.y = (noise.get_noise_3d(0,time * time_scale,0) * max_y * shaking)
	rot=(noise.get_noise_3d(time * time_scale,0,0) * max_r * shaking)
	#
	zoom=Vector2(lerp(zoom.x,3.8*added_zoom,20*delta/Engine.time_scale),lerp(zoom.y,3.8*added_zoom,20*delta/Engine.time_scale))
	if shake > 0: 
		shake = clamp(shake -(delta * timer),0,1)
