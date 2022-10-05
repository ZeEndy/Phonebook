extends Node2D

@export var point=0
@export var point_stuff=[]
@export var saved=false
@export var level_complete=false

@export var song: String

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_nodes_in_group("EDITOR").size()==0:
		if saved==false:
			saved=true
			get_tree().get_root().get_node("GAME").save_node_state("restart_scene",self)
			get_tree().get_root().get_node("GAME").save_node_state("checkpoint",self)
		if level_complete==false && song!="":
			get_tree().get_nodes_in_group("GLOBAL")[0].play_song(song)
		

func _process(_delta):
	if get_tree().get_nodes_in_group("EDITOR").size()==0:
		if Input.is_action_pressed("DEBUG_ABILTY"):
			Engine.time_scale=0.05
		else:
			Engine.time_scale=1
		
		if Input.is_action_just_pressed("reload"): # && get_tree().get_nodes_in_group("Player").size()==0:
			get_tree().get_root().get_node("GAME").cursor_position=get_tree().get_nodes_in_group("Cursor")[0].real_mouse
			if Input.is_action_pressed("far_look"):
				get_tree().get_root().get_node("GAME").switch_scene("user://restart_scene.scn",true,false)
			else:
				get_tree().get_root().get_node("GAME").switch_scene("user://checkpoint.scn",true,true)
		if get_tree().get_nodes_in_group("Enemy").size()==0 && get_tree().get_nodes_in_group("CUTSCENE").size()==0 && level_complete==false:
			level_complete=true
			get_tree().get_nodes_in_group("GLOBAL")[0].play_song("Music/Videodrome.ogg")

func _save_checkpoint():
	get_tree().get_root().get_node("GAME").save_node_state("checkpoint",self)
