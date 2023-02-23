extends Node


#onready var resource_queue=get_node("root/resource_queue")

var saved = false

var load_=false



#var restart_scene
#var checkpoint


var time=1.0


#config stuff

var fullscreen=0
var windowed_mouse=false

var particle_quality=0
#0 no particles
#1 minimal particles
#3 all particles
var light_quality=0


var _saving=false

var new_room

var cursor_position=null

var configfile


var discord_rich 


var paused=false

#func _ready():
#	yield(get_tree().create_timer(0.1),"timeout")
#	save_node_state("checkpoint",get_tree().get_nodes_in_group("Level")[0])
#	save_node_state("restart_scene",get_tree().get_nodes_in_group("Level")[0])

var fade=false
var fade_color = 1



var music_volume=0
var sfx_volume=0
var mas_volume=0

var given_track
var target_volume=0

signal fade_out
var fade_out_emitted=false
signal fade_in
var fade_in_emitted=false

#@onready var music=get_node("Music") 
@onready var glob_fade=get_node("CanvasLayer/Fade")

func _init():
	configfile = ConfigFile.new()
	if configfile.load("res://config.cfg") == OK:
#		for audio in configfile.get_section_keys("AUDIO"):
		music_volume=configfile.get_value("AUDIO","Music")
		sfx_volume=configfile.get_value("AUDIO","SFX")
		mas_volume=configfile.get_value("AUDIO","Master")
		print("CONFIG: "+str(configfile.get_value("AUDIO","Master")))
#		for quality in configfile.get_section_keys("QUALITY"):
		particle_quality=configfile.get_value("QUALITY","particle_quality")
		light_quality=configfile.get_value("QUALITY","light_quality")
	else:
		print(configfile.load("res://config.cfg"))
#		InputMap
#	await RenderingServer.frame_post_draw
	
#	activate_discord()

func _ready():
	get_node("CanvasLayer2/DEBUG_TEXT").visible=OS.is_debug_build()
	configfile = ConfigFile.new()
	if configfile.load("res://config.cfg") == OK:
		for cursor in configfile.get_section_keys("CURSOR"):
			GUI.set(cursor,configfile.get_value("CURSOR",cursor))






func _process(delta):
	var t_delta=delta/Engine.time_scale
	if Input.is_action_just_pressed("Pause"):
		paused=!paused
	if paused==true:
		Engine.time_scale=lerp(Engine.time_scale,0.00005,10*t_delta)
	else:
		Engine.time_scale=lerp(float(time),1.0,10*t_delta)
#	OS.set_window_title("PhoneBook " + " | fps: " + str(Engine.get_frames_per_second()))
#	if Input.is_action_just_pressed("ui_end"):
#		change_presence_image()
	if Input.is_action_just_pressed("Debug_exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("DEBUG_FULLSCREEN"):
		if fullscreen==DisplayServer.WINDOW_MODE_FULLSCREEN:
			fullscreen=DisplayServer.WINDOW_MODE_WINDOWED
		else:
			fullscreen=DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)



	if Input.is_action_just_pressed("DEV_SAVE"):
		save_node_state("checkpoint",get_tree().get_nodes_in_group("Level")[0])


#	get_node("CanvasLayer/Noise").material.set_shader_param("giv_time",delta*randf_range(0.767845,1.697665))
	#fade
	glob_fade.scale=Vector2(get_viewport().size.y*2,get_viewport().size.x*2)

	if fade==false: 
		if fade_color>0:
			fade_in_emitted=false
			fade_out_emitted=false
			fade_color-=delta*5 
		else:
			fade_color=0
			if fade_out_emitted==false:
				emit_signal("fade_out")
				fade_out_emitted=true
	else:
		if fade_color<1:
			fade_in_emitted=false
			fade_out_emitted=false
			fade_color+=delta*5
		else:
			fade_color=1
			if fade_in_emitted==false:
				emit_signal("fade_in")
				fade_in_emitted=true
	glob_fade.modulate.a=fade_color
	get_node(
		"CanvasLayer2/DEBUG_TEXT"	).text="Build version :"+str(Engine.get_version_info().string)+"\n"+"FPS:"+str(Performance.get_monitor(0))+"\n"+"Texture Memory used:"+str(Performance.get_monitor(21)/10000000)+"\n"+"Process time:"+str(Performance.get_monitor(1))+"\n"+"Physics process time:"+str(Performance.get_monitor(2))+"\n"+"Draw calls:"+str(Performance.get_monitor(19))+"\n"+"Objects in game"+str(Performance.get_monitor(8))
	pass
#saves nodes and shit in the node tree
func save_node_state(_file_name,node):
	_saving=true
	var saved_scene
	
	var root_node=node
	
	var packed_scene = PackedScene.new()
	
	_set_owner(root_node,root_node)
	packed_scene.pack(node)
	saved_scene=ResourceSaver.save(packed_scene,"user://"+_file_name+".scn")
	
	_saving=false
	print("saved on file: "+_file_name)
	return saved_scene


func quit_level():
	get_tree().quit()

func _set_owner(node, root):
	if node is SubViewport && node in get_tree().get_nodes_in_group("Surface"):
		node.save_surface()
	if node != root:
		node.owner = root
		if node.scene_file_path!="":
			node.scene_file_path=""
	for child in node.get_children():
		_set_owner(child, root)



func exit_game():
	fade=true
	await fade_in==true
	get_tree().quit(0)


#objects can call this function to either switch to a level or menu or something idk
func switch_scene(file):
	if _saving==false:
		fade=true
		await fade_in==true
		if fade_color==1:
			get_tree().call_deferred("change_scene_to_file",file)
			fade=false



func _enter_tree():
	discord_rich==true

func _on_GAME_fade_in():
	return true


func _on_GAME_fade_out():
	return true
