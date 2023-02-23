extends Node2D

@onready var weapon_preload=preload("res://Data/DEFAULT/ENTS/ENT_GENERIC_WEAPON.tscn")

@export var point=0
@export var point_stuff=[]
@export var saved=false
@export var level_complete=false
@export var combat_level=true

var checkpoint=[]
var restart=[]

@export var song:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_nodes_in_group("EDITOR").size()==0:
		if saved==false:
			saved=true
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			checkpoint=save_level()
			restart=save_level()
		if level_complete==false && song!=null:
			GAME.play_song(song)

func _process(_delta):
	if get_tree().get_nodes_in_group("EDITOR").size()==0:
		
		if Input.is_action_just_pressed("DEBUG_SAVE"):
			_save_checkpoint()
		
		if Input.is_action_just_pressed("reload") && get_tree().get_nodes_in_group("Player").size()==0:
			GAME.cursor_position=GUI.real_mouse
			if Input.is_action_pressed("far_look"):
				load_level(restart)
			else:
				load_level(checkpoint)
#		if get_tree().get_nodes_in_group("Enemy").size()==0 && get_tree().get_nodes_in_group("CUTSCENE").size()==0 && level_complete==false:
#			level_complete=true
#			GAME.play_song("res://Data/Music/mu_Rot.ogg")
func _save_checkpoint():
#	GAME.save_node_state("checkpoint",self)
	checkpoint=save_level()

func save_level():
	var save_array=[]
	for x in get_children(true):
		if x is SubViewportContainer:
			for i in x.get_child(0).get_children():
				if i is PED:
					var dict={
						"id":i,
						"parent_id":i.get_parent(),
						"variables":{
						"state":i.state,
						"sprite_index":i.sprite_index,
						"leg_index":i.leg_index,
						"body_direction":i.body_direction,
						"gun":i.gun.duplicate(true),
						"health":i.health,
						"global_position":i.collision_body.global_position,
						"delay":i.delay,
						}
					}
					if i is Player:
						dict["variables"].merge({
						"override_movement":i.override_movement,
						"override_attack":i.override_attack,
						"override_pick_up":i.override_pick_up,
						"override_look":i.override_look
						})
#					if i is Enemy:
#						dict["variables"].merge({
#						"act":i.act,
#						})
					save_array.append(dict)
				if i is WEAPON:
					save_array.append({
						"id":"Weapon",
						"parent_id":i.get_parent(),
						"global_position":i.global_position,
						"rotation":i.rotation,
						"gun":i.gun
					})
				if i is goresurf:
					save_array.append({
						"id":i,
						"surf_data":i.surface_data.duplicate(true),
						"avalible_sprites":i.avalible_sprites.duplicate(true)
					})
				if i is Door:
					save_array.append({
						"id":i,
						"door_rot":i.door_anc.rotation,
						"swingspeed":i.swingspeed
					})
	return save_array


func set_child(child,property,value):
	child.set_deferred(property,value)

func get_group(strg):
	var return_array=[]
	if get_tree().get_nodes_in_group(strg)!=null:
		return_array=get_tree().get_nodes_in_group(strg)
	return return_array

func load_level(array):
#	print("fuck")
#	print(save_CUNT)
	for i in get_group("Weapon")+get_group("Particles"):
		i.queue_free()
	for i in array:
		var id = i["id"]
		if id is String:
			if id=="Weapon":
				var wep=weapon_preload.instantiate()
				i["parent_id"].add_child(wep)
				wep.global_position=i["global_position"]
				wep.global_rotation=i["rotation"]
				wep.gun=i["gun"]
		else:
			if id is PED:
				id._ready()
				id.reparent(i["parent_id"])
				for x in i["variables"]:
					if i["variables"][x] is Dictionary || i["variables"][x] is Array:
						id.set_deferred(x,i["variables"][x].duplicate(true))
					else:
						id.set(x,i["variables"][x])
						if x == "global_position":
							id.collision_body.position=Vector2(0.0,0.0)
			if id is goresurf:
				id.surface_data=i["surf_data"].duplicate(true)
				id.avalible_sprites=i["avalible_sprites"].duplicate(true)
				id._ready()
			if id is Door:
				id.door_anc.rotation=i["door_rot"]
				id.swingspeed=i["swingspeed"]

