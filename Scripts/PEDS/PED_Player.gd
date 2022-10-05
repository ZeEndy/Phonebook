extends PED

class_name Player


# Typing in a abilty for the player character lets know what abilty to use i.e. rolldoge, killing punches, tony punches, ect 
@export var ability = "Rolldodge"
@export var saved_ability_variable=[]
@export var ability_active=""
@export var ability_override_movement=false
@export var override_pick_up=false
@export var override_attack=false
var cursor_pos = null
@export var camera_obj=0


func _physics_process(delta):
	#usless code
#	if Input.is_action_just_pressed("ui_accept"):
#		sprite_index="MaskOn"
	get_node("PED_COL").global_rotation = 0
	if state == ped_states.alive:
		if Input.is_action_just_pressed("interact"):
			switch_weapon()
		#movement axis
		axis = Vector2(Input.get_action_strength("right")-Input.get_action_strength("left"),Input.get_action_strength("down")-Input.get_action_strength("up"))
		
		#incase you want to disable movement
		if ability_override_movement==false:
			movement(null,delta)
		
		if Input.is_action_just_pressed("execute"):
			do_execution()
		ability_activate()
		#change weapon fire modes can be use later but change it so that it goes trough an array that you make in the weapon dictonary
#		if Input.is_action_just_pressed("switch_mode") && gun.trigger_pressed==false:
#			if gun.type=="semi":
#				gun.type="burst"
#			else:
#				gun.type="semi"
		
		
		#INPUT MANAGMENT
		if override_attack==false:
			if Input.is_action_just_pressed("attack"):
				gun.trigger_pressed=true
		if Input.is_action_just_released("attack") && gun.type=="semi":
			gun.trigger_pressed=false
		if Input.is_action_just_released("attack") && gun.type=="auto":
			gun.trigger_pressed=false
		if Input.is_action_just_released("attack") && gun.type=="melee":
			gun.trigger_pressed=false
		if  gun.type=="burst" && gun.trigger_shot==0 && delay==0:
			if !(Input.is_action_pressed("attack")):
				gun.trigger_pressed=false
		fability(delta)
	if state == ped_states.abilty:
		#rolldodge and shit like that use it here
		fability(delta)
	
func _process(_delta):
	debug_rand_weapon()
	#reload for weapons
	if Input.is_action_just_pressed("debug_reload_kunt"):
		reload_non_wad()
	#instance the camera dynamically just incase the CAMERA group is empty and it isn't in a EDITOR
	#Editor part can be removed since the editor no longer exists but can be used incase you make your own
	if get_tree().get_nodes_in_group("Camera3D").size()==0 && get_tree().get_nodes_in_group("EDITOR").size()==0:
		var new_camera=Camera2D.new()
		new_camera.zoom=Vector2(1,1)*0.3
		new_camera.add_to_group("Camera3D")
		new_camera.current=true
		new_camera.global_position=global_position
		get_parent().get_parent().add_child(new_camera)
		new_camera.smoothing_enabled=true
		new_camera.smoothing_speed=6
		var script=load("res://Scripts/GAMEPLAY/GAMEPLAY_CAMERA.gd")
		new_camera.set_script(script)
		new_camera.set_process(true)
	if get_tree().get_nodes_in_group("Cursor").size()==0 && get_tree().get_nodes_in_group("EDITOR").size()==0:
		var new_cursor=load("res://Data/DEFAULT/ENTS/ENT_Cursor.tscn")
		var inst_cursor=new_cursor.instantiate()
		get_parent().add_child(inst_cursor)
	if state == ped_states.alive:
		#make sure that the cursor has been changed to a Vector2 so that they don't point to null causing a crash
		if cursor_pos != null:
			body_direction = -cursor_pos.angle_to(Vector2(1,0))
			#old MGL code to determine granade launchers distance and to determine far look's distance
			given_height = cursor_pos.length()*0.006
		
		
		#boring ass camera position based checked the body sprite's position and rotation 
		if get_tree().get_nodes_in_group("Camera3D").size()>0 && get_tree().get_nodes_in_group("EDITOR").size()==0:
			if Input.is_action_pressed("far_look"):
				#far look based checked given_height use *70 to change how far you want it go
				get_tree().get_nodes_in_group("Camera3D")[0].global_position=sprites.global_position+Vector2(24+given_height*70,0).rotated(body_direction)
			else:
				get_tree().get_nodes_in_group("Camera3D")[0].global_position=sprites.global_position+Vector2(24,0).rotated(body_direction)
		sprites.get_node("Body").global_rotation = body_direction
	elif state == ped_states.execute:
		if get_tree().get_nodes_in_group("Camera3D").size()>0 && get_tree().get_nodes_in_group("EDITOR").size()==0:
				get_tree().get_nodes_in_group("Camera3D")[0].global_position=sprites.global_position
				if execute_click==true:
					if Input.is_action_just_pressed("attack"):
						execute_do_click()

#function to start and ability
func ability_activate():
	if ability_active=="":
		if "Rolldodge" in ability && axis.length()!=0 && Input.is_action_just_pressed("execute") && in_distance_to_execute==false:
			sprites.get_node("Legs").animation="Roll"
			sprites.get_node("Legs").frame=0
			sprites.get_node("Legs").global_rotation=sprites.get_node("Body").global_rotation
			sprites.get_node("Body").visible=false
			state=ped_states.abilty
			ability_active="Rolldodge"



func fability(delta):
	if ability_active!="":
		#roll dodge
		#do it if you have sprite other wise it wont work
		if ability_active=="Rolldodge":
			if !Input.is_action_pressed("execute"):
				if sprites.get_node("Legs").frame<12 && sprites.get_node("Legs").frame>4:
					sprites.get_node("Legs").frame=12
				
			sprites.get_node("Legs").rotation=lerp_angle(sprites.get_node("Legs").rotation,atan2(my_velocity.y,my_velocity.x),50*delta)
			movement(Vector2(1,0).rotated(axis.angle())*(MAX_SPEED+50),delta)
			
			sprites.get_node("Legs").speed_scale=0.3
			if get_tree().get_nodes_in_group("Camera3D").size()>0 && get_tree().get_nodes_in_group("EDITOR").size()==0:
				get_tree().get_nodes_in_group("Camera3D")[0].global_position=sprites.global_position
			if change_leg_sprite_value==true:
				sprites.get_node("Legs").animation="WalkLegs"
				sprites.get_node("Body").visible=true
				state=ped_states.alive
				ability_active=""
				change_leg_sprite_value=false
		if ability_active=="Reload_custom":
			if change_sprite_value==true:
				gun.ammo=gun.max_ammo

func reload_non_wad():
	if gun.has("max_ammo"):
		if gun.ammo<=gun.max_ammo:
			#get the list of sprites and create 2 variables
			var list_of_sprites=sprites.get_node("Body").frames.get_animation_list()
			var normal_reload=""
			var empty_reload=""
			#get the list of avalible reloads for a specific gun ID
			for i in list_of_sprites:
				if "Reload"+gun.id in i && "_Start" in i && !("Empty" in i):
					normal_reload=i
					break
			for i in list_of_sprites:
				if "Reload"+gun.id in i && "_StartEmpty" in i:
					empty_reload=i
					break
			#check if both of them aren't empty so that sprite_index isn't empty
			if normal_reload!="" or empty_reload!="":
				#Whats up guys it is a bluedrake and today we're gonna suck alot of cock and talk about this
				#tactical releastic weapon reload animation manager that falls back if one of the animations is missing
				if gun.ammo>0:
					if normal_reload!="":
						sprite_index=normal_reload
					else:
						sprite_index=empty_reload
				else:
					if empty_reload!="":
						sprite_index=empty_reload
					else:
						sprite_index=normal_reload


#function used for some if checks
func get_class():
	return "Player"


#debug weapon spawner for the lolz
func debug_rand_weapon():
		if Input.is_action_just_pressed("DEBUG_SPAWN_GUN"):
			var random_weapon=int(round(randf_range(0,5)))
			drop_weapon()
			match random_weapon:
				0:#M(
					var transfer_gun={
						#id for hud
						"id":"M9",
						#ammo of the gun
						"ammo":12,
						"max_ammo":12,
						# wad sprites
						"walk_sprite":"WalkM9",
						"attack_sprite":["AttackM9"],
						"attack_index":0,
						#random checked attack
						"random_sprite":false,
						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_M9.wav",
						
						
						"kill_sprite":"DeadMachinegun",
						"kill_lean_sprite":"DeadLeanMachinegun",
						
						"recoil":4,
						
						"droppable":true,
						#types:melee,burst,semi,auto
						"type":"semi",
						#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
						"attack_type":"normal",
						
						
						"execution_sprite":"ExecuteM9",
						"ground_sprite":"DieShot",
						"gun_length":0,
						"screen_shake":1,
						
						#trigger
						"trigger_pressed":false,
						"trigger_bullets":0,
						"trigger_reset":0.1,
						"trigger_shot":0,
						"shoot_bullets":1
					}
					gun=dupe_dict(transfer_gun)
				1:#AK
					var transfer_gun={
						#id for hud
						"id":"AK",
						#ammo of the gun
						"ammo":31,
						"max_ammo":30,
						# wad sprites
						"walk_sprite":"WalkAK",
						"attack_sprite":["AttackAK"],
						"attack_index":0,
						#random checked attack
						"random_sprite":false,
						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/sndAK.wav",
						
						
						"kill_sprite":"DeadMachinegun",
						"kill_lean_sprite":"DeadLeanMachinegun",
						
						"recoil":4,
						
						"droppable":true,
						#types:melee,burst,semi,auto
						"type":"auto",
						#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
						"attack_type":"armor",
						
						
						"execution_sprite":"",
						"ground_sprite":"",
						"gun_length":0,
						"screen_shake":1,
						
						#trigger
						"trigger_pressed":false,
						"trigger_bullets":0,
						"trigger_reset":0.1,
						"trigger_shot":0,
						"shoot_bullets":1
					}
					gun=dupe_dict(transfer_gun)
				2:#M16
					var transfer_gun={
						#id for hud
						"id":"M16",
						#ammo of the gun
						"ammo":21,
						"max_ammo":20,
						# wad sprites
						"walk_sprite":"WalkM16",
						"attack_sprite":["AttackM16"],
						"attack_index":0,
						#random checked attack
						"random_sprite":false,
						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/sndM16.wav",
						
						
						"kill_sprite":"DeadMachinegun",
						"kill_lean_sprite":"DeadLeanMachinegun",
						
						"recoil":4,
						
						"droppable":true,
						#types:melee,burst,semi,auto
						"type":"burst",
						#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
						"attack_type":"armor",
						
						
						"execution_sprite":"",
						"ground_sprite":"",
						"gun_length":0,
						"screen_shake":1,
						
						#trigger
						"trigger_pressed":false,
						"trigger_bullets":3,
						"trigger_reset":0.1,
						"trigger_shot":0,
						"shoot_bullets":1
					}
					gun=dupe_dict(transfer_gun)
				3:#SHOTGUN
					var transfer_gun={
						#id for hud
						"id":"Shotgun",
						#ammo of the gun
						"ammo":7,
						"max_ammo":6,
						# wad sprites
						"walk_sprite":"WalkShotgun",
						"attack_sprite":["AttackShotgun"],
						"attack_index":0,
						#random checked attack
						"random_sprite":false,
						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_Shotgun.wav",
						
						
						"kill_sprite":"DeadShotgun",
						"kill_lean_sprite":"DeadLeanShotgun",
						
						"recoil":8,
						
						"droppable":true,
						#types:melee,burst,semi,auto
						"type":"semi",
						#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
						"attack_type":"armor",
						
						
						"execution_sprite":"ExecuteShotgun",
						"ground_sprite":"DieShotgun",
						"gun_length":0,
						"screen_shake":1,
						
						#trigger
						"trigger_pressed":false,
						"trigger_bullets":0,
						"trigger_reset":0.8,
						"trigger_shot":0,
						"shoot_bullets":8
					}
					gun=dupe_dict(transfer_gun)
				4:#KNIFE
					var transfer_gun={
						#id for hud
						"id":"Knife",
						#ammo of the gun
						"ammo":7,
						"max_ammo":6,
						# wad sprites
						"walk_sprite":"WalkKnife",
						"attack_sprite":["AttackKnife"],
						"attack_index":0,
						#random checked attack
						"random_sprite":false,
						"attack_sound":"",
						
						
						"kill_sprite":"DeadSlash",
						"kill_lean_sprite":"DeadLeanMelee",
						
						"recoil":8,
						
						"droppable":true,
						#types:melee,burst,semi,auto
						"type":"melee",
						#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
						"attack_type":"",
						
						
						"execution_sprite":"ExecuteKnife",
						"ground_sprite":"DieKnife",
						"gun_length":0,
						"screen_shake":1,
						
						#trigger
						"trigger_pressed":false,
						"trigger_bullets":0,
						"trigger_reset":0,
						"trigger_shot":0,
						"shoot_bullets":0
					}
					gun=dupe_dict(transfer_gun)
				5:#Bat
					var transfer_gun={
						#id for hud
						"id":"Bat",
						#ammo of the gun
						"ammo":7,
						"max_ammo":6,
						# wad sprites
						"walk_sprite":"WalkBat",
						"attack_sprite":["AttackBat"],
						"attack_index":0,
						#random checked attack
						"random_sprite":false,
						"attack_sound":"",
						
						
						"kill_sprite":"DeadBlunt",
						"kill_lean_sprite":"DeadLeanMelee",
						
						"recoil":8,
						
						"droppable":true,
						#types:melee,burst,semi,auto
						"type":"melee",
						#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
						"attack_type":"",
						
						
						"execution_sprite":"ExecuteBat",
						"ground_sprite":"DieBlunt",
						"gun_length":0,
						"screen_shake":1,
						
						#trigger
						"trigger_pressed":false,
						"trigger_bullets":0,
						"trigger_reset":0.8,
						"trigger_shot":0,
						"shoot_bullets":0
					}
					gun=dupe_dict(transfer_gun)
# :face_with_raised_eyebrow: old code
#				3:#MGL
#
#					var transfer_gun={
#						#id for hud
#						"id":"MGL",
#						#ammo of the gun
#						"ammo":6,
#						"max_ammo":6,
#						# wad sprites
#						"walk_sprite":"WalkMGL",
#						"attack_sprite":["AttackMGL"],
#						"attack_index":0,
#						#random checked attack
#						"random_sprite":false,
#						#flip checked attack
#						"flip_sprite":false,
#
#						"sound_index":0,
#						"random_attack_sounds":true,
#						"attack_sound":["snd9mm"],
#						"random_kill_sounds":true,
#						"kill_sound":[],
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"auto",
#						"screen_shake":20,
#
#						#bullet:| shotgun, normal, armor, grenade
#						"attack_type":"grenade",
#						"gun_length":24,
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":0,
#						"trigger_reset":0.4,
#						"trigger_shot":0,
#						"shoot_bullets":1
#						}
#					gun=dupe_dict(transfer_gun)
			sprite_index = gun.walk_sprite
