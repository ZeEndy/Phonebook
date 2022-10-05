extends Node2D

class_name WINDOW

@export var destroyed=false
@export var destruction_sounds=["res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_Glass1.wav","res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_Glass2.wav"]

func _ready():
	get_node("Sprite2D").speed_scale=0
	

func _process(_delta):
	if destroyed==false:
		var collisions=window_collision_check()
		if collisions.size()>0:
			destroy_window()
	

func destroy_window():
	if destroyed==false:
		get_node("Sprite2D").frame=1
		play_audio(destruction_sounds[randf_range(0,destruction_sounds.size()-1)])
		destroyed=true


func window_collision_check():
	var collision_objects=[]
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(get_node("StaticBody2D/CollisionShape2D").shape)
	query.collision_layer=264
	
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(global_rotation,global_position))
	collision_objects=space.intersect_shape(query,5)
	
	var return_array=[]
	for i in collision_objects:
		if (i.collider is BULLET or i.collider is WEAPON):
			return_array.append([i.collider])
	return return_array


func play_audio(given_sample,affected_time=true,true_pitch=1,random_pitch=0,bus="Master"):
	if (given_sample is String):
		var audio_player := AudioStreamPlayer.new()
		audio_player.stream = AudioManager.get_audio_stream(given_sample)
		#gonna add this script later but gonna need to probably rethink about that
		audio_player.set_script(load("res://Scripts/AUDIO/AUDIO_STREAM_SOUND.gd"))
		audio_player.affected_time=affected_time
		get_parent().get_parent().call_deferred("add_child",audio_player)
		audio_player.current_pitch=true_pitch+randf_range(-random_pitch,random_pitch)
		audio_player.autoplay = true
		audio_player.set_bus(bus) 
	elif given_sample is Array:
		if (typeof(given_sample[0])==1 && given_sample[0]==false):
			play_audio(given_sample[randf_range(1,given_sample.size()-1)],affected_time,true_pitch,random_pitch,bus)
		else:
			for i in given_sample:
				play_audio(i,affected_time,true_pitch,random_pitch,bus)
	
	
	
	
	




