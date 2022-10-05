extends Node2D

class_name DrivableVehicle

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var driver_steat
var axis=Vector2(0,0)

var drive_axis=Vector2()

var engine_on=false
var engine_rpm=0
var start_engine=false

var gear=1
var wait_rpm=0
@export var gear_ratio=[-0.3,0.4,0.6,0.8,1,1.2]
@export var engine_start_rpm=0
@export var idle_rpm=0
@export var throttle=0
@export var max_rpm=0
@export var sound_library=[]
@export var turn_radius=60

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	axis.x=Input.get_action_strength("right")-Input.get_action_strength("left")
	get_node("Smoothing2D/TireLeft").rotation_degrees=lerp(get_node("Smoothing2D/TireLeft").rotation_degrees,axis.x*turn_radius,0.25)
	get_node("Smoothing2D/TireRight").rotation_degrees=lerp(get_node("Smoothing2D/TireRight").rotation_degrees,axis.x*turn_radius,0.25)
	var bodies = get_node("Smoothing2D/Seat/Area2D").get_overlapping_bodies()
	for i in bodies:
		if i.get_parent() is Player:
			if !(i.global_position.distance_to(get_node("Smoothing2D/Seat").global_position)<5.5):
				i.get_parent().ability_override_movement=true
				var distance_slowdown=clamp(i.global_position.distance_to(get_node("Smoothing2D/Seat").global_position),5.5,10000)-2.25
				i.get_parent().movement(i.global_position.direction_to(get_node("Smoothing2D/Seat").global_position).normalized()*(50*(distance_slowdown*0.1)),delta)
			else:
				i.position=Vector2(0,0)
				i.get_parent().global_position=Vector2(0,0)
				var piss = i.get_parent()
				i.get_parent().get_parent().remove_child(piss)
				get_node("Smoothing2D/Seat").add_child(piss)
				i.get_parent().axis=Vector2.ZERO
				i.get_node("CollsionCircle").disabled=true
				i.get_parent().override_attack=true
				i.get_parent().override_pick_up=true
				if engine_on==false:
					get_node("Smoothing2D/AnimationPlayer").play("Engine")
					for sound in sound_library:
						get_node(sound[0]).playing=true
					engine_on=true
	if engine_on==true:
		axis.y=Input.get_action_strength("up")-Input.get_action_strength("down")
		if engine_rpm>max_rpm:
			gear=clamp(gear+1,1,gear_ratio.size()-1)
			if gear!=gear_ratio.size()-1:
				engine_rpm-=throttle*4*(60*delta)
				wait_rpm=engine_rpm-throttle*3
			else:
				engine_rpm-=throttle*3*(60*delta)
		else:
			if engine_rpm<idle_rpm:
				if axis.y!=0:
					gear=clamp(gear-1,1,gear_ratio.size()-2)
				else:
					gear=0
				engine_rpm+=throttle*(60*delta)
			engine_rpm-=throttle*(60*delta)*0.3
			if wait_rpm==0:
				if gear!=0:
					var poop=gear_ratio[gear]
					engine_rpm+=(throttle*poop)*(60*delta)*axis.y
				else:
					engine_rpm+=throttle*(60*delta)*(-axis.y)
			else:
				if engine_rpm<wait_rpm:
					wait_rpm=0
		print(gear)
		if engine_rpm>idle_rpm*1.2:
			var gear_final=abs(-1-gear_ratio[gear])
			drive_axis=Vector2(((engine_rpm-idle_rpm)*0.1)*(gear_final),0)
			get_node("CharacterBody2D").global_rotation+=get_node("Smoothing2D/TireRight").rotation*drive_axis.length()*delta*0.005
			get_node("CharacterBody2D").move_and_collide(drive_axis.rotated(get_node("CharacterBody2D").global_rotation)*delta)
		


func _process(_delta):
	audio_process()



func audio_process():
	if engine_on==true:
		for sound in sound_library:
			if get_node(sound[0]).playing==false:
				get_node(sound[0]).playing=true
		get_node("Smoothing2D/AnimationPlayer").seek(lerp(get_node("Smoothing2D/AnimationPlayer").current_animation_position,engine_rpm/max_rpm,0.8))
