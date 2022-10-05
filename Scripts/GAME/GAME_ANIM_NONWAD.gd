extends Node2D

class_name anim_mang
#work around lol
var frames = self

@export var speed_scale=1
@export var frame=0
@export var animation=""
@export var saved_var={}
@export var add_to_surface=false
@export var spawn_pos_on_tree: NodePath
var wait_to_flip=false

# Called when the node enters the scene tree for the first time.


func get_animation_list():
	return get_node("AnimationPlayer").get_animation_list()

func play(_animation:String = 'default',giv_frame=0, backwards:bool = false, speed:float = 1.0) -> void:
	if backwards==false:
		get_node("AnimationPlayer").play(_animation,-1)
	else:
		get_node("AnimationPlayer").play_backwards(_animation,-1)
	speed_scale=speed

func _process(delta):
	frame=get_node("AnimationPlayer").current_animation_position
	animation=get_node("AnimationPlayer").current_animation
	get_node("AnimationPlayer").playback_speed=speed_scale

func add_ammo(ammount=1):
	if get_node("../../").gun.ammo+ammount<=get_node("../../").gun.max_ammo:
		get_node("../../").gun.ammo+=ammount
	else:
		get_node("../../").gun.ammo=get_node("../../").gun.max_ammo+1
	

func change_anim_on_full(anim):
	if get_node("../../").gun.ammo >= get_node("../../").gun.max_ammo:
		get_node("../../").sprite_index=anim
	else:
		get_node("AnimationPlayer").seek(0)
	pass


func change_anim_on_bolt(anim):
	#this function is only for reload animations
	if !(get_node("../../").gun.ammo == get_node("../../").gun.max_ammo):
		get_node("../../").sprite_index=anim
		get_node("../../").override_attack=false


#used for shotguns
func pump(next_anim):
	if get_node("../../").gun.ammo>0:
		get_node("../../").sprite_index=next_anim

func shake_screen(ammount:int):
	get_tree().get_nodes_in_group("Camera3D")[0].shake=ammount


func flip_sprite_switch(next_anim):
	#used for attacks
	wait_to_flip=true
	get_node("../../").sprite_index=next_anim
	
func flip_sprite():
	#used for attacks
	get_node("anim").scale.y=-get_node("anim").scale.y
#sets time based checked ammo
func set_frame_ammo(frame_rate:int,frame:int,repeat=0.0):
#	if get_node("../../").gun.ammo>0:
	if get_node("../../").execute_remove_health(0,repeat)!=true:
		set_frame(frame_rate,frame)
		

func move_rot_relative(added_pos:Vector2=Vector2(0,0)):
	#moves an object relative to the animation objects rotation
	get_node("../../PED_COL").global_position+=added_pos.rotated(global_rotation)
	get_node("../").teleport()

func has_animation(input_anim):
	if input_anim in get_node("AnimationPlayer").get_animation_list():
		return true

func play_audio(given_sample,pos_2d=null,affected_time=true,true_pitch=1,random_pitch=0,bus="SFX"):
	AudioManager.play_audio(given_sample,pos_2d,affected_time,true_pitch,random_pitch,bus)


func spawn_object(path_to_object:String,pos:Vector2,rot:float,set_stuff:Array=[]):
	#set stuff just do [[get variable,the value to set it as],[get 2nd variable,the value to set it as]]
	if path_to_object!="":
		var object = load(path_to_object).instantiate()
		object.global_position=global_position+pos.rotated(global_rotation)
		object.global_rotation=global_rotation+rot
		for i in set_stuff:
			if i[0]=="casing_linear_velocity":
				var add_on_speed=Vector2.ZERO
				var casing_angle=i[1].angle()
				var casing_speed=Vector2(randf_range(i[1].length()*0.4,i[1].length()),0).rotated(casing_angle)
				if get_parent().get_parent() is PED:
					add_on_speed=get_parent().get_parent().my_velocity
				object.set("linear_velocity",casing_speed.rotated(global_rotation+randf_range(deg_to_rad(-20),deg_to_rad(20)))+add_on_speed)
			else:
				object.set(i[0],i[1])
		get_node(spawn_pos_on_tree).get_parent().add_child(object)

#need to calculate acording to the frame rate
func set_frame(frame_rate:int = 13,frame:int = 0):
	seek( (1/float(frame_rate))*float(frame) ,true )
#same thing but I do it to the next frame
func next_frame(frame_rate:int = 13):
	seek(frame+(1/float(frame_rate)) ,true)
#	print(frame+(1/float(frame_rate)))

func seek(seconds:float = 0.0,update:bool = true):
	get_node("AnimationPlayer").seek(seconds,update)

func print_debug_anim():
	print(get_node("anim").scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_started(anim_name):
	if wait_to_flip==true:
		get_node("AnimationPlayer").seek(get_node("AnimationPlayer").current_animation_position,true)
		get_node("anim").scale.y=-get_node("anim").scale.y
		wait_to_flip=false
