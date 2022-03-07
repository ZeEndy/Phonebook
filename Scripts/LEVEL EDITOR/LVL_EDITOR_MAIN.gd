extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var level=get_node("level")
#well self explanatory
export (NodePath) var current_floor
export var level_name="TEST LEVEL"
#idk where I'm going with this
export var fart_check=true
var floors=[]

var ent_spawn_list=[
	"res://Data/DEFAULT/ENTS/PED_PLAYER.tscn",
	"res://Data/DEFAULT/ENTS/ENT_GENERIC_WEAPON.tscn",
	"Weapon"
]
export var weapon_ent_list=[
	#M16
	{
		#id for hud
		"id":"M16",
		
		#sprites
		"walk_sprite":"WalkM16",
		"attack_sprite":["AttackM16"],
		"attack_index":0,
		#random on attack
		"random_sprite":false,
		#flip on attack
		"flip_sprite":false,
		
		#types:melee,semi,burst
		"type":"burst",
		"avalible_types":["semi","burst","auto"],
			#bullet:| shotgun, normal, armor, grenade
		"bullet":"",
		
		#kill sound like hitting a ped or shooting
		"attack_sound":[""],
		#swing sound for melee
		"swing_sound":[""],
		
		
		#ammo of the gun
		"ammo":25,
		#max ammo for hud and reload
		"clip_ammo":25,
		
		#path of the scene
		"path":"res://Data/DEFAULT/ENTS/ENT_GENERIC_WEAPON.tscn",
		
		#trigger
		"trigger_pressed":false,
		"trigger_bullets":3,
		"trigger_shot":0,
		#amount of bullets spawned by 1 shot
		"shoot_bullets":1,
		"trigger_reset":0.1,
		
		#smoke trail
		"smoke":false,
		"smoke_timer":0},
	
]

func _ready():
	filename=""
	if floors==[]:
		create_floor()
		current_floor=floors[0]


func _process(_delta):
	if Input.is_action_just_pressed("switch_mode"):
		add_new_ent(ent_spawn_list[0])
	if Input.is_action_just_pressed("interact"):
		add_new_ent(ent_spawn_list[1])
	if Input.is_action_just_pressed("ui_up"):
		play_level()
	if Input.is_action_just_pressed("DEV_SAVE"):
		fart_check=true
		get_tree().get_root().get_node("GAME").save_node_state(level_name+"_editor_test",self)
		

func create_floor():
	var new_floor=Node2D.new()
	new_floor.name="floor"+String(floors.size()+1)
	level.add_child(new_floor)
	floors.append(new_floor)

func play_level():
	export_level()
	get_tree().get_root().get_node("GAME").switch_scene("user://"+level_name+"_playable.scn",true,false)
	queue_free()


func add_new_ent(ent_id):
	var new_ent=load(ent_id).instance()
	new_ent.global_position=get_viewport().get_mouse_position()
	current_floor.add_child(new_ent)
	yield(get_tree().create_timer(0.01),"timeout")
	for child in new_ent.get_children():
		child.set_process(false)
		child.set_physics_process(false)
	new_ent.set_process(false)
	new_ent.set_physics_process(false)


func export_level():
	get_node("level").add_to_group("Current_room",true)
	get_tree().get_root().get_node("GAME").save_node_state(level_name+"_playable",get_node("level"))
	get_node("level").remove_from_group("Current_room")
func save_level_editor():
	get_tree().get_root().get_node("GAME").save_node_state(level_name+"_editor",self)



func _on_TextEdit_text_changed():
	level_name=get_node("TextEdit").text
