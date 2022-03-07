extends Node


#onready var resource_queue=get_node("root/resource_queue")

var saved = false

var load_=false


var _vsync=true

var _file =""
var _fade=false
var _activate_switch=false
var _instant=false
var _loading=false
var _last_file=""
var _replaced_room=false
var _replace_room
var fullscreen=false

var _saving=false

var new_room

var cursor_position=null

var configfile

#func _ready():
#	yield(get_tree().create_timer(0.1),"timeout")
#	save_node_state("checkpoint",get_tree().get_nodes_in_group("Level")[0])
#	save_node_state("restart_scene",get_tree().get_nodes_in_group("Level")[0])


func _ready():
	configfile = ConfigFile.new()
	if configfile.load("res://config.ini") == OK:
		for audio in configfile.get_section_keys("AUDIO"):
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio),configfile.get_value("AUDIO",audio))


func _process(_delta):
	if Input.is_action_just_pressed("DEBUG_FULLSCREEN"):
		fullscreen=!fullscreen
		OS.set_window_fullscreen(fullscreen)
	OS.set_window_title("PhoneBook " + " | fps: " + str(Engine.get_frames_per_second()))
	
	
	
	if Input.is_action_just_pressed("DEV_SAVE"):
		save_node_state("checkpoint",get_tree().get_nodes_in_group("Level")[0])
	
	
	
	
	if _activate_switch==true:
		_active_switch_scene(_fade,_instant)
	
	
#saves nodes and shit in the node tree
func save_node_state(_file_name,node):
	_saving=true
	var saved_scene
	
	var root_node=node
	
	var packed_scene = PackedScene.new()
	
	_set_owner(root_node,root_node)
	packed_scene.pack(node)
	
	saved_scene=ResourceSaver.save("user://"+_file_name+".scn", packed_scene)
	
	_saving=false
	print("saved on file: "+_file_name)
	return saved_scene

#usless fucntions
#func load_checkpoint(_userdata):
#	switch_scene("user://checkpoint_scene.scn",true,true,false)
#
#func load_restart(_userdata):
#	switch_scene("user://restart_scene.scn",true,false,true)

#trolling
func quit_level():
	get_tree().quit()

func _set_owner(node, root):
	if node is Viewport && node in get_tree().get_nodes_in_group("Surface"):
		node.save_surface()
	if node != root:
		node.owner = root
		if node.filename!="":
			node.filename=""
	for child in node.get_children():
		_set_owner(child, root)



#func is_instanced_from_scene(p_node):
#	#check if its a file that way it doesnt make duplicates
#	if not p_node.filename.empty():
#		return true
#	#saving the surface for blood fx and shit
#	if p_node 
#	return false

#objects can call this function to either switch to a level or menu or something idk
func switch_scene(file,fade,inst):
	if _activate_switch==false:
		_activate_switch=true
		_instant=inst
		if _instant==false:
			new_room=ResourceLoader.load_interactive(file)
		else:
			new_room=load(file)
		_fade=fade
	


func _active_switch_scene(fade,instant):
	if _saving==false:
		if fade==true:
				if instant==false:
					get_node("GLOBAL").fade=true
					if get_node("GLOBAL").fade_color==1:
						if get_tree().get_nodes_in_group("Current_room").size()>0:
							get_tree().get_nodes_in_group("Current_room")[0].queue_free()
						else:
							#ERR_FILE_EOF means that file is loaded into memory and can be instanced
							print(new_room.poll())
							if new_room.poll()==ERR_FILE_EOF:
								var replace_room=new_room.get_resource().instance()
								add_child(replace_room)
								get_node("GLOBAL").fade=false
								new_room=null
								_activate_switch=false
				else:
					get_node("GLOBAL").fade=true
					if get_node("GLOBAL").fade_color==1:
						if get_tree().get_nodes_in_group("Current_room").size()>0:
							get_tree().get_nodes_in_group("Current_room")[0].queue_free()
							var replace_room=new_room.instance()
							add_child(replace_room)
							get_node("GLOBAL").fade=false
							new_room=null
							_activate_switch=false




#	if _saving==false:
#		if fade==true:
#				if instant==false:
#					get_node("GLOBAL").fade=true
#					if get_node("GLOBAL").fade_color==1:
#						if get_tree().get_nodes_in_group("Current_room").size()>0:
#							get_tree().get_nodes_in_group("Current_room")[0].queue_free()
#
#						else:
#							#ERR_FILE_EOF means that file is loaded into memory and can be instanced
#							if new_room.poll()==ERR_FILE_EOF:
#								var replace_room=new_room.get_resource().instance()
#								add_child(replace_room)
#								get_node("GLOBAL").fade=false
#								new_room=null
#								_activate_switch=false
#				else:
#					get_node("GLOBAL").fade=true
#					if get_node("GLOBAL").fade_color==1:
#						if get_tree().get_nodes_in_group("Current_room").size()>0:
#							get_tree().get_nodes_in_group("Current_room")[0].queue_free()
#							new_room.wait()
#							if new_room.poll()==ERR_FILE_EOF:
#								yield(get_tree().create_timer(0.01),"timeout")
#								var replace_room=new_room.get_resource().instance()
#								add_child(replace_room)
#								get_node("GLOBAL").fade=false
#								new_room=null
#								_activate_switch=false

