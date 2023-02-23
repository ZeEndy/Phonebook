extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var stream_script=preload("res://Scripts/AUDIO/AUDIO_STREAM_SOUND.gd")
var stream_amb=preload("res://Scripts/AUDIO/AUDIO_AMBIENT.gd")
var stream_script_2d=preload("res://Scripts/AUDIO/AUDIO_STREAM_SOUND_2D.gd")
var saved_audio_files={
}


var target_song
@onready var mus_vol=GAME.music_volume
@onready var sfx_vol=GAME.sfx_volume
@onready var mas_vol=GAME.mas_volume
@onready var music=get_node("Music")
var target_volume=0
var given_track=null
var paused=false



func _process(delta):
	var t_delta=delta/Engine.time_scale
	paused=GAME.paused
	mus_vol=GAME.music_volume
	sfx_vol=GAME.sfx_volume
	mas_vol=GAME.mas_volume
	AudioServer.set_bus_volume_db(0,mas_vol)
	AudioServer.set_bus_volume_db(1,mus_vol)
	AudioServer.set_bus_volume_db(2,sfx_vol)
	
	
	if music.stream!=given_track:
		if music.playing:
			target_volume = -80
			if music.volume_db < -79.9:
				music.stream=given_track
				music.playing=true
				target_volume=0
		else:
			music.volume_db=-80
			music.stream=given_track
			music.playing=true
			target_volume=0

	if music.volume_db!=target_volume:
		if music.volume_db<target_volume:
			music.volume_db+=(delta*5)*80
		elif music.volume_db>target_volume:
			music.volume_db-=(delta*5)*80

	music.volume_db=clamp(music.volume_db,-80,0)

func play_song(given_location="res://Data/DEFAULT/SOUNDS/snd_selector_bg2.ogg"):
	if (given_location!=null or given_location!=""):
		if given_location is AudioStream:
			given_track=given_location
		else:
			given_track=load(given_location)
	else:
		if given_location=="":
			music.stop()
			music.autoplay=false

#optimizing the ammount of times the audio stream needs to get made
func get_audio_stream(stream_path):
	for path in saved_audio_files.keys():
		if stream_path == path:
			return saved_audio_files[path]
	var loaded_audio=load(stream_path)
	saved_audio_files[stream_path]=loaded_audio
	return loaded_audio


func play_amb(given_sample,effect=""):
	var audio_player=AudioStreamPlayer.new()
	audio_player.set_script(stream_amb)
	add_child(audio_player)
	audio_player.stream=get_audio_stream(given_sample)
	audio_player.efx=effect
	audio_player.play()
	

#this function is depricated
func play_audio(given_sample,pos_in_2d=null ,affected_time=true,true_pitch=1,random_pitch=0,bus="Master"):
	pass
##	print(pos_in_2d)
#	if (given_sample is String):
#		var audio_player
#		if pos_in_2d==null:
#			audio_player=AudioStreamPlayer.new()
#			audio_player.set_script(stream_script)
#		else:
#			audio_player=AudioStreamPlayer2D.new()
#			audio_player.set_script(stream_script_2d)
#			audio_player.global_position=pos_in_2d
#		audio_player.stream = get_audio_stream(given_sample)
#		audio_player.autoplay=true
#		audio_player.affected_time=affected_time
#		audio_player.current_pitch=true_pitch+randf_range(-random_pitch,random_pitch)
#		if pos_in_2d==null:
#			add_child(audio_player)
#		else:
#			return audio_player
#		audio_player.set_bus(bus)
#	elif given_sample is Array:
#		if (typeof(given_sample[0])==1 && given_sample[0]==false):
#			play_audio(given_sample[randi_range(1,given_sample.size()-1)],pos_in_2d,affected_time,true_pitch,random_pitch,bus)
#		else:
#			for i in given_sample:
#				play_audio(i,pos_in_2d,affected_time,true_pitch,random_pitch,bus)
