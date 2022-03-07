extends Node


var game_is_active=false
var fade=false
var fade_color = 1
var soundtrack_wad=null
var _wad=null

var given_track
var target_volume=0


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(VisualServer,"frame_post_draw")
	game_is_active=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("CanvasLayer/Noise").material.set_shader_param("giv_time",delta*rand_range(0.767845,1.697665))
	#fade
	get_node("CanvasLayer/Fade").scale=Vector2(get_viewport().size.y*2,get_viewport().size.x*2)
	get_node("CanvasLayer/Noise").scale=Vector2(get_viewport().size.y*2,get_viewport().size.x*2)
	if game_is_active==true:
		if fade==false: 
			if fade_color>0:
				fade_color-=delta*5 
			else:
				fade_color=0
		else:
			if fade_color<1:
				fade_color+=delta*5
			else:
				fade_color=1
	get_node("CanvasLayer/Fade").modulate.a=fade_color
	
	get_node(
		"CanvasLayer2/DEBUG_TEXT"
		).text="Build version :"+str(ProjectSettings.get("global/game_version"))+"\n"+"FPS:"+String(Performance.get_monitor(0))+"\n"+"Texture Memory used:"+String(Performance.get_monitor(21)/10000000)+"\n"+"Process time:"+String(Performance.get_monitor(1))+"\n"+"Physics process time:"+String(Performance.get_monitor(2))+"\n"+"Draw calls:"+String(Performance.get_monitor(19))+"\n"+"Objects in game"+String(Performance.get_monitor(8))
	
	
	#music
	if get_node("Music").stream!=given_track:
		if get_node("Music").playing:
			target_volume = -80
			if get_node("Music").volume_db < -79.9:
				get_node("Music").stream = given_track
				get_node("Music").playing=true
				target_volume=0
		else:
			get_node("Music").volume_db=-80
			get_node("Music").stream=given_track
			get_node("Music").playing=true
			target_volume=0
	
	if get_node("Music").volume_db!=target_volume:
		if get_node("Music").volume_db<target_volume:
			get_node("Music").volume_db+=(delta*5)*80
		elif get_node("Music").volume_db>target_volume:
			get_node("Music").volume_db-=(delta*5)*80
	
	get_node("Music").volume_db=clamp(get_node("Music").volume_db,-80,0)

func play_song(given_location="res://Data/DEFAULT/SOUNDS/snd_selector_bg2.ogg"):
	if (given_location!=null or given_location!=""):
		given_track=load(given_location)
	else:
		if given_location=="":
			get_node("Music").stop()
			get_node("Music").autoplay=false
