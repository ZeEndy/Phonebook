class_name anim_mang
extends Node2D

#work around lol
var frames = self


@onready var ped_parent=get_node("../../")
@onready var anim_player=get_node("AnimationPlayer")
@onready var sprite=get_node("anim")

@export var speed_scale=1
@export var frame=0
@export var animation=""
@export var saved_var={}
@export var add_to_surface=false
@export_node_path var spawn_pos_on_tree
var wait_to_flip=false


# Called when the node enters the scene tree for the first time.

func get_animation_list():
	return anim_player.get_animation_list()

func play(_animation:String = 'default', backwards:bool = false, speed:float = 1.0) -> void:
	if backwards==false:
		anim_player.stop()
		anim_player.play(_animation,-1)
		anim_player.speed_scale=speed
		anim_player.seek(0)
		animation=_animation
		speed_scale=1
		
	else:
		anim_player.play_backwards(_animation,-1)
		speed_scale=-1
		animation=_animation
		
	



#func _process(delta):
#	if get_node("AnimationPlayer").current_animation!="":
#		frame=get_node("AnimationPlayer").current_animation_position
#		animation=get_node("AnimationPlayer").current_animation
#		get_node("AnimationPlayer").playback_speed=speed_scale


func holster(anim:String,pull_out:bool):
	if pull_out==false:
		ped_parent.holster=ped_parent.gun.duplicate(true)
		ped_parent.gun=ped_parent.default_gun.duplicate(true)
		play(anim)
		ped_parent.sprite_index=anim
		print("holster_full")
	else:
		ped_parent.sprite_index=anim
		ped_parent.gun=ped_parent.holster.duplicate(true)
		ped_parent.holster=null
		play(anim)
		print("holster_empty")

func add_ammo(ammount=1):
	if ped_parent.gun.ammo+ammount<=ped_parent.gun.max_ammo:
		ped_parent.gun.ammo+=ammount
	else:
		ped_parent.gun.ammo=ped_parent.gun.max_ammo+1

func shake_screen(shake_in:float=0.11,adative:bool=true):
	if ped_parent is Player:
		get_tree().get_nodes_in_group("Glob_Camera_pos")[0].add_shake(shake_in,adative)

func change_anim_on_full(anim):
	if ped_parent.gun.ammo >= ped_parent.gun.max_ammo || ped_parent.gun["reserve"]==0:
		ped_parent._play_animation(anim)
#		print("cock")
	else:
		ped_parent._play_animation(animation)
#		print("dick")
	pass

func set_body_dir(dir):
	ped_parent.body_direction=global_rotation+dir


func change_anim_on_full_single(anim):
	if ped_parent.gun.ammo >= ped_parent.gun.max_ammo || ped_parent.gun["reserve"]==0:
		ped_parent._play_animation(anim)
		print("BRO THIS SHOULD ALREADY CHANGEEAAAAAA")
	else:
		anim_player.seek(0.0)

func full_or_almost_full(anim,anim_alt,ammo_from_max=0):
	if ped_parent.gun.ammo+ammo_from_max >= ped_parent.gun.max_ammo:
		ped_parent._play_animation(anim_alt)
	else:
		ped_parent._play_animation(anim)
	pass

func change_anim_on_almost_full(anim):
	if ped_parent.gun.ammo == ped_parent.gun.max_ammo-1 || ped_parent.gun["reserve"]-1==0:
		ped_parent._play_animation(anim)
	else:
		anim_player.seek(0)
	pass

func change_anim_on_bolt(anim):
	#this function is only for reload animations
	if !(ped_parent.gun.ammo >= ped_parent.gun.max_ammo):
		ped_parent._play_animation(anim)
		ped_parent.override_attack=false

func change_anim_on_full_tube(anim,offset=0):
	if (ped_parent.gun.ammo+offset >= ped_parent.gun.max_ammo || ped_parent.gun.reserve==0):
		ped_parent._play_animation(anim)

#used for shotguns
func pump(next_anim):
	if ped_parent.gun.amo>0:
		ped_parent._play_animation(next_anim)


func clear_jam():
	ped_parent.gun["jammed"]=false

func flip_sprite_switch(next_anim):
	#used for attacks
	wait_to_flip=true
	ped_parent._play_animation(next_anim)
	
func flip_sprite():
	#used for attacks
	sprite.scale.y=-sprite.scale.y

#sets time based on gun.ammo
func set_frame_ammo(frame_rate:int,frame:int,repeat=0.0):
#	if ped_parent.gun.ammo>0:
	if ped_parent.execute_remove_health(0,repeat)!=true:
		set_frame(frame_rate,frame)

func move_rot_relative(added_pos:Vector2=Vector2(0,0)):
	#moves an object relative to the animation objects rotation
	ped_parent.collision_body.global_position+=added_pos.rotated(global_rotation)
	print(get_parent().name)
	get_parent().call_deferred("s_teleport")

func has_animation(input_anim):
	if input_anim in anim_player.get_animation_list():
		return true

func play_audio(given_sample,pos_2d=null ,affected_time:bool=true,true_pitch:float=1.0,random_pitch:float=0.0,bus:String="SFX"):
#	print(given_sample)
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
			if i[0]=="z_index":
#				print(get_parent().get_parent().z_index)
				object.set("z_index",get_parent().get_parent().z_index+i[1])
		get_viewport().call_deferred("add_child",object)

#need to calculate acording to the frame rate
func set_frame(frame_rate : int = 13,fframe : int = 0):
	seek( (1/float(frame_rate))*float(fframe) ,true )
#same thing but I do it to the next frame
func next_frame(frame_rate : int = 13):
	seek(frame+(1/float(frame_rate)) ,true )
#	print(er+(1/float(frame_rate)))

func seek(seconds:float = 0.0,update:bool = true):
	anim_player.seek(seconds,update)

#func print_debug_anim():
#	print(get_node("anim").scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func call_gui_anim(anim):
	GUI.play(anim)

func _on_AnimationPlayer_animation_started(_anim_name):
	if wait_to_flip==true:
		anim_player.seek(anim_player.current_animation_position,true)
		sprite.scale.y=-sprite.scale.y
		wait_to_flip=false

