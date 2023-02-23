extends PED

class_name Player

var glob_delta=0
var glob_phys_delta=0

var interact_target={}

signal interact_anim_finish()
signal interact_pos_reached()

# Typing in a abilty for the player character lets know what abilty to use i.e. rolldoge, killing punches, tony punches, ect 
@export var ability = ""
@export var saved_ability_variable=[]
@export var ability_active=""
@export var override_movement=false
@export var override_look=false
@export var override_pick_up=false
@export var override_attack=false
var cursor_pos = Vector2(0,0)
@export var camera_obj=0
@export var axis_multiplier=1.0
var tap_countdown=0.0
var rotation_multip=1.0
var retard_reset=false

var injector_inv=[["Kerenzikov",5]]
var active_injector=""
var active_inj_timer=0.0

@export var in_combat=true



var bullet_container=[]


var after_image_reset=0.0




@onready var CAMERA=get_tree().get_nodes_in_group("Glob_Camera_pos")[0]
@onready var cam_track=get_node("PED_SPRITES/Body/CameraTrack")
#@onready var turn_angle=sprite_body.global_rotation
#@export var cursor=null
#
func print_test():
	print("test")

func _ready():
	super()
	CAMERA.target=cam_track
#	if typeof(cursor)!=17:
#		var new_cursor=load("res://Data/DEFAULT/ENTS/ENT_Cursor.tscn")
#		var inst_cursor=new_cursor.instantiate()
#		get_parent().call_deferred("add_child",inst_cursor)
#		cursor=inst_cursor
	

func _physics_process(delta):
	super(delta)
	glob_phys_delta=delta
	if Input.is_action_just_pressed("weapon_swap"):
		holster_gun()
	if Input.is_action_just_pressed("ui_accept"):
		sprite_index="MaskOn"
	get_node("PED_COL").global_rotation = 0
	if state == ped_states.alive:
		if in_combat==true && override_pick_up==false:
			if Input.is_action_just_pressed("interact"):
				switch_weapon()
			if Input.is_action_just_pressed("Inject"):
				_play_animation("Inject"+sprite_index.replace(gun["id"]+"/Walk",""))
		if in_combat==true && Input.is_action_just_pressed("execute"):
			do_execution()
		
		if interact_target=={}:
			axis = Vector2(Input.get_action_strength("right")-Input.get_action_strength("left"),Input.get_action_strength("down")-Input.get_action_strength("up"))*axis_multiplier
		else:
			print(rad_to_deg(interact_target.pos.angle_to_point(collision_body.global_position)))
			axis = Vector2(1,0).rotated(collision_body.global_position.angle_to_point(interact_target.pos))
			print(collision_body.global_position.distance_to(interact_target.pos))
			override_look=true
			body_direction=lerp_angle(body_direction,interact_target.rot,clamp(15*delta,0,1))
			if collision_body.global_position.distance_to(interact_target.pos)<2.0:
				collision_body.global_position=interact_target.pos
				body_direction=lerp(body_direction,interact_target.rot,1.0)
				axis = Vector2(0,0)
				my_velocity=Vector2(0,0)
				interact_target={}
				interact_pos_reached.emit()
				
		if override_movement==false:
			movement(null,delta)


#		if Input.is_action_just_pressed("switch_mode") && gun.trigger_pressed==false:
#			if gun.type=="semi":
#				gun.type="burst"
#			else:
#				gun.type="semi"
		
		
		
		if override_attack==false && in_combat==true:
			if gun!={}:
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


func _process(delta):
	glob_delta=delta
	super(delta)
	if gun.has("reserve"):
		GUI.ammo=gun.ammo
		GUI.max_ammo=gun.max_ammo
		get_node("PED_COL/Label").text=str(gun.ammo)+"/"+str(gun.max_ammo)
	debug_rand_weapon()
	
	if active_injector!="":
		if active_inj_timer>0:
			active_inj_timer-=delta/Engine.time_scale
			injector_active(delta)
		else:
			active_injector=""
			Engine.time_scale=1
			health=clamp(health,0,100)
			motion_multiplier=1
	
	
	
	if state == ped_states.alive:
		cursor_pos=GUI.mouse
		GUI.p_pos=sprite_body.get_screen_transform().origin
		if cursor_pos != null:
			if override_look==false:
				body_direction = lerp_angle(body_direction,-cursor_pos.angle_to(Vector2(1,0)),clamp(40*rotation_multip*delta,0,1))
				rotation_multip=lerp(rotation_multip,1.0,clamp(25*delta,0,1))
				given_height = cursor_pos.length()*0.0018
				if CAMERA!=null:
					if Input.is_action_pressed("far_look"):
						cam_track.position=Vector2(32+given_height*70,0)
					else:
						cam_track.position=Vector2(24,0)
		sprites.get_node("Body").global_rotation = body_direction
	elif state == ped_states.execute:
		if CAMERA!=null:
			CAMERA.global_position=sprites.global_position
		if execute_click==true:
			if Input.is_action_just_pressed("attack"):
				execute_do_click()

func do_remove_health(damage,killsprite:String="DeadBlunt",rot:float=randf()*180,frame="rand",body_speed=2,_bleed=false):
	get_tree().get_nodes_in_group("Glob_Camera_pos")[0].add_shake(damage/10,true)
	if armour>0:
		AudioManager.play_audio([false,
		"res://Data/Sounds/Generic/Armour Hit/impact_helmet_1p_1.wav",
		"res://Data/Sounds/Generic/Armour Hit/impact_helmet_1p_2.wav",
		"res://Data/Sounds/Generic/Armour Hit/impact_helmet_1p_3.wav",
		"res://Data/Sounds/Generic/Armour Hit/impact_helmet_1p_4.wav"],
		null,true,1.0,0.0,"SFX")
	body_direction+=randf_range(deg_to_rad(10),deg_to_rad(20))* ([-1,1][randi_range(0,1)])
	rotation_multip=0.2
	super(damage,killsprite,rot,frame,body_speed,_bleed)

#func double_tap():
#	await get_tree().create_timer(0.2).timeout
#	if (gun["reserve"] is Array && gun.has("reserve")==true && gun["reserve"].size()>0) or (gun["reserve"]>0): 
#		print(tap_count)
#		if tap_count<2:
#			reload_anim(false)
#			tap_count=0
#			return
#		else:
#			reload_anim(true)
#			tap_count=0
#			return

func ability_activate():
	pass
#	if ability_active=="":
#		if "Rolldodge" in ability && axis.length()!=0 && Input.is_action_just_pressed("execute") && in_distance_to_execute==false:
#			sprites.get_node("Legs").animation="Roll"
#			sprites.get_node("Legs").frame=0
#			sprites.get_node("Legs").global_rotation=sprites.get_node("Body").global_rotation
#			sprites.get_node("Body").visible=false
#			state=ped_states.abilty
#			ability_active="Rolldodge"
#		if "Reload_custom" in ability && sprite_index==gun.walk_sprite && sprites.get_node("Body").has_animation("spr"+whoami.replace(".","Reload")) && Input.is_action_just_pressed("reload"):
#			pass



func injector_active(delta):
	for i in Database.injector_database[active_injector]["variables"].keys():
		match i:
			"injector_timer":
				pass
#			print(i+" set to: "+str(Database.injector_database[active_injector][i]))
			"time_scale":
				Engine.set_deferred(i,Database.injector_database[active_injector]["variables"][i])
			_:
				set_deferred(i,Database.injector_database[active_injector]["variables"][i])
	for i in Database.injector_database[active_injector]["methods"]:
		callv(i[0],i[1])
		

func injector_use():
	if injector_inv.size()>0:
		active_injector=injector_inv[0][0]
		active_inj_timer=Database.injector_database[active_injector]["variables"]["injector_timer"]
		GUI.chromatic=0.1
#		callv()
#		print(active_inj_timer)
		



func Kerenzikov_effect():
	if active_inj_timer>=Database.injector_database[active_injector]["variables"]["injector_timer"]-glob_delta:
		AudioManager.play_audio("res://Data/Sounds/UI/Notif_time_slowdown.wav",null,false,1,0,"SFX")
		AudioManager.play_amb("res://Data/Sounds/UI/Amb_slowmotion.wav","slowmo")
		CAMERA.added_zoom=1.15
		
	if active_inj_timer<0.55 && active_inj_timer+glob_delta/Engine.time_scale>=0.55:
		AudioManager.play_audio("res://Data/Sounds/UI/Notif_time_speedup.wav")
	if active_inj_timer<2.0:
		GUI.pulse_speed=lerp(GUI.pulse_speed,1.0,clamp(glob_delta/Engine.time_scale,0,1))
		if active_inj_timer<0.01:
			GUI.pulse_speed=1.0
	else:
		GUI.pulse_speed=lerp(GUI.pulse_speed,15.0,clamp(35*glob_delta/Engine.time_scale,0,1))
	if active_inj_timer<0.01:
		CAMERA.added_zoom=1
	
	if after_image_reset==0:
		var mirrage=AnimatedSprite2D.new()
		var body_anim=sprite_body.get_node("anim")
		mirrage.set_script(load("res://Scripts/VFX/VFX_Kereznikov.gd"))
		add_child(mirrage)
		mirrage.frames=body_anim.frames
		mirrage.animation=body_anim.animation
		mirrage.offset=body_anim.offset
		mirrage.frame=body_anim.frame
		mirrage.global_position=body_anim.global_position
		mirrage.global_rotation=body_anim.global_rotation
		mirrage.modulate=Color.from_hsv(fmod(active_inj_timer*0.5,1.0),0.3,1.0,1.0)
		mirrage.z_index-=1
		after_image_reset=0.1
	else:
		after_image_reset=clamp(after_image_reset-(glob_delta/Engine.time_scale),0,1)
		
#func _unhandled_input(event):
#	if state==ped_states.alive:
#		if event.is_action_pressed("scroll_up") or event.is_action_pressed("scroll_down"):
#			holster_gun()


func holster_gun():
	if (gun.walk_sprite in sprite_index):
		if holster==null:
			if gun.id!=default_gun.id:
				print("holster_empty")
				var holst=gun.get("holster")
				var empty_holst=gun.get("holster_empty")
				var cur_sprite_index=""
				if gun.ammo>0:
					if holst!=null:
						cur_sprite_index=holst
					else:
						cur_sprite_index=empty_holst
				else:
					if empty_holst!=null:
						cur_sprite_index=empty_holst
					else:
						cur_sprite_index=holst
				if cur_sprite_index!="" && cur_sprite_index!=null:
					sprite_body.play(cur_sprite_index,false)
					sprite_index=cur_sprite_index
					
		if holster!=null:
			drop_weapon()
			print("holster_full")
			var holst=holster.get("unholster")
			var empty_holst=holster.get("unholster_empty")
			var cur_sprite_index=""
			if holster.ammo>0:
				if holst!=null:
					cur_sprite_index=holst
				else:
					cur_sprite_index=empty_holst
			else:
				if empty_holst!=null:
					cur_sprite_index=empty_holst
				else:
					cur_sprite_index=holst
			if cur_sprite_index!="":
				sprite_body.play(cur_sprite_index,false)
				sprite_index=cur_sprite_index
				



#func drop_weapon(throw_speed=1,dir=null):
#	sprite_body.get_node("anim/BARREL").visible=false
#	super(throw_speed,dir)



func get_class():
	return "Player"


func debug_rand_weapon():
		if Input.is_action_just_pressed("DEBUG_SPAWN_GUN"):
			var rand_list=["M9","Shotgun","M16"]
			var random_select=int(round(randf_range(0,rand_list.size()-1)))
			drop_weapon()
			gun=Database.get_wep(rand_list[random_select])
			sprite_index = ""


func attack(sound_pos=null):
	super(sound_pos)



func fuck_around_anim():
#	print("worky")
	pass

func _play_animation(animation:String,frame=0,global=false):
	print(animation)
	super(animation,frame,global)


#func _on_animation_player_animation_changed(old_name, new_name):



func _on_animation_player_animation_started(anim_name):
	if  ("Insert_shell" in anim_name) || ("Reload" in anim_name) || ("Clear" in anim_name):
		GUI.show_mag_timer=2.5
		GUI.show_ammo_timer=2.5

func interact_anim_signal():
	interact_anim_finish.emit()
