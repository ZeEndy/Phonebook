extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var stream_script=preload("res://Scripts/AUDIO/AUDIO_STREAM_SOUND.gd")
var stream_script_2d=preload("res://Scripts/AUDIO/AUDIO_STREAM_SOUND_2D.gd")
var saved_audio_files={
}





#optimizing the ammount of times the audio stream needs to get made
func get_audio_stream(stream_path):
	for path in saved_audio_files.keys():
		if stream_path == path:
			return saved_audio_files[path]
	var loaded_audio=load(stream_path)
	saved_audio_files[stream_path]=loaded_audio
	return loaded_audio


func play_audio(given_sample,pos_in_2d=null ,affected_time=true,true_pitch=1,random_pitch=0,bus="Master"):
	if (given_sample is String):
		var audio_player
		if pos_in_2d==null:
			audio_player=AudioStreamPlayer.new()
			audio_player.set_script(stream_script)
		else:
			audio_player=AudioStreamPlayer2D.new()
			audio_player.set_script(stream_script_2d)
			audio_player.global_position=pos_in_2d
		audio_player.stream = get_audio_stream(given_sample)
		audio_player.affected_time=affected_time
		audio_player.current_pitch=true_pitch+rand_range(-random_pitch,random_pitch)
		audio_player.play()
		audio_player.set_bus(bus) 
		add_child(audio_player)
	elif given_sample is Array:
		if (typeof(given_sample[0])==1 && given_sample[0]==false):
			play_audio(given_sample[rand_range(1,given_sample.size()-1)],pos_in_2d,affected_time,true_pitch,random_pitch,bus)
		else:
			for i in given_sample:
				play_audio(i,pos_in_2d,affected_time,true_pitch,random_pitch,bus)
