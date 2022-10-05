extends Node2D

class_name Door

#reference variables
@onready var door_anc=get_node("DOOR_ANCHER")

@export var swingspeed=0
var swingdir=0
@export var swinger=0


var active=0
var door_size=Vector2(0,0)
@export var PED_SCALE=8


@export var locked = false
@export var spring_return=false

@export var door_flip=1

var _wad=null




func _ready():
	$DOOR_ANCHER/Sprite2D.scale.y=door_flip
	door_size=get_node("DOOR_ANCHER/Sprite2D").texture.get_size()

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
		if (abs(swingspeed) > 0):
			door_anc.rotation_degrees =door_anc.rotation_degrees + (swingspeed*delta*60)
			if (door_anc.rotation_degrees < -135):
				door_anc.rotation_degrees = -135
				swingspeed = abs(swingspeed)
			if (door_anc.rotation_degrees > 135):
				door_anc.rotation_degrees = 135
				swingspeed = (- abs(swingspeed))
			swingdir = sign(swingspeed)
			if (abs(swingspeed) < 3.5):
				if ((door_anc.rotation_degrees > -6) && (door_anc.rotation_degrees < 6)):
					swingspeed = 0
					door_anc.rotation_degrees = 0
			if (swingspeed > 0.25):
				swingspeed = (swingspeed - 0.25*delta*60)
			elif (swingspeed < -0.25):
				swingspeed = (swingspeed + 0.25*delta*60)
			else:
				swinger = 0
				swingspeed = 0
				active=0
		else:
			if spring_return==true:
				if door_anc.rotation_degrees != 0:
					door_anc.rotation_degrees=lerp(door_anc.rotation_degrees,0,0.02)
		Collision_trollface()




func play_sample(given_sample,affected_time=true,true_pitch=1,random_pitch=0,bus="Master"):
#	print(given_sample)
	if (given_sample is String):
		pass
#		var audio_player := AudioStreamPlayer2D.new()
#		audio_player.stream = _wad.audio_stream(given_sample+".wav",true)
#		#gonna add this script later but gonna need to probably rethink about that
#		audio_player.set_script(load("res://Scripts/AUDIO/AUDIO_STREAM_SOUND_2D.gd"))
#		audio_player.affected_time=affected_time
#		get_parent().get_parent().call_deferred("add_child",audio_player)
#		audio_player.current_pitch=true_pitch+randf_range(-random_pitch,random_pitch)
#		audio_player.autoplay = true
#		audio_player.set_bus(bus) 
#		audio_player.global_position=global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)
	elif given_sample is Array:
		if (typeof(given_sample[0])==1 && given_sample[0]==false):
			print("type of is 1")
			play_sample(given_sample[randf_range(1,given_sample.size()-1)],affected_time,true_pitch,random_pitch,bus)
		else:
			for i in given_sample:
				play_sample(i,affected_time,true_pitch,random_pitch,bus)
	return true


func Collision_trollface():
	var b = door_collision_checker()
	for i in b:
		if active==0 or active==1:
			if i[0] is Player && !locked:
				if active==0:
					active=i[1]
				else:
					active=1
				swinger=1
				if abs(swingspeed)<2:
					play_sample("sndDoorOpen")
					var line_pos=global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)
					var add_on_speed=clamp(abs(1.15-i[2].distance_to(line_pos)-PED_SCALE),1,1.15)
					swingspeed=(7*add_on_speed)
				return
			if i[0] is Enemy && !locked:
				if active==0:
					active=i[1]
				else:
					active=1
				if swinger==1:
					if i[0].state==0:
						i[0].go_down(door_anc.global_rotation+randf_range(deg_to_rad(-45),deg_to_rad(45)))
						play_sample("sndDoorHit")
				else:
					if abs(swingspeed)<2:
						play_sample("sndDoorOpen")
					var line_pos=global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)
					var add_on_speed=clamp(abs(1.15-i[2].distance_to(line_pos)-PED_SCALE),1,1.15)
					swingspeed=(7*add_on_speed)
				return
		elif active==0 or active==-1:
			if i[0] is Player && !locked:
				if active==0:
					active=i[1]
				else:
					active=-1
				swinger=1
				if abs(swingspeed)<2:
					play_sample("sndDoorOpen")
				var line_pos=global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)
				var add_on_speed=clamp(abs(1.15-i[2].distance_to(line_pos)-PED_SCALE),1,1.15)
				swingspeed=-(7*add_on_speed)
				return
			if i[0] is Enemy && !locked:
				if active==0:
					active=i[1]
				else:
					active=-1
				if swinger==1:
					if i[0].state==0:
						i[0].go_down(door_anc.global_rotation+randf_range(deg_to_rad(-45),deg_to_rad(45)))
						play_sample("sndDoorHit")
				else:
					if abs(swingspeed)<2:
						play_sample("sndDoorOpen")
					var line_pos=global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)
					var add_on_speed=clamp(abs(1.15-i[2].distance_to(line_pos)-PED_SCALE),1,1.15)
					swingspeed=-(7*add_on_speed)
				return


func door_collision_checker():
	var collision_objects=[]
	var shape = RectangleShape2D.new()
	shape.extents=door_size/2
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.collision_layer=5
	
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(door_anc.global_rotation, global_position+Vector2(door_size.x/2,0).rotated(door_anc.global_rotation)))
	collision_objects+=space.intersect_shape(query,5)
	
	for ang in abs(round(swingspeed)):
		var space2 = get_world_2d().direct_space_state
		query.set_transform(Transform2D(door_anc.global_rotation+deg_to_rad(ang*active), global_position+Vector2(door_size.x/2,0).rotated(door_anc.global_rotation+deg_to_rad(ang*active))))
		collision_objects+=space2.intersect_shape(query,5)
	
	var return_array=[]
	for i in collision_objects:
		if !(i.collider is StaticBody2D):
			var line_pos=global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)
			var direction=line_pos.direction_to(i.collider.global_position).angle()
			var test=0
			if angle_difference(door_anc.global_rotation,direction)>deg_to_rad(90) && angle_difference(door_anc.global_rotation,direction)<deg_to_rad(180):
				test=-1
			else:
				test=1
			return_array.append([i.collider.get_parent(),test,i.collider.global_position])
	return return_array


static func angle_difference(from, to):
	return fposmod(to-from + PI, PI*2) - PI
