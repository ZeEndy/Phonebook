extends Node2D
class_name PED
#preloads
onready var def_bullet_ent=preload("res://Data/DEFAULT/ENTS/ENT_BULLET.tscn")
onready var def_grenade_ent=preload("res://Data/DEFAULT/ENTS/ENT_GRENADE.tscn")


#reference variables
onready var sprites = get_node("PED_SPRITES")
onready var sprite_body = get_node("PED_SPRITES/Body")
onready var sprite_legs = get_node("PED_SPRITES/Legs")
onready var collision_body = get_node("PED_COL")


#variables are oragnized by specification aka what state they are used the most in
enum ped_states{
	alive,
	abilty,
	execute,
	down,
	dead
}
var state = ped_states.alive


#ALIVE STATE VARIABLES
var health=1
export var start_with_gun=false
# Movement variables
const MAX_SPEED = 225
const ACCELERATION = 0.20
const DECEL_MULTIP = 0.75
export var my_velocity=Vector2()
var friction_multip = 1
var axis = Vector2()
var motion_multiplier=1
var path=[]


#WEAPON VARIABLES
export var delay=0
var default_gun={
	#id for hud
	"id":"Unarmed",
	#ammo of the gun
	"ammo":0,
	"max_ammo":0,
	# wad sprites
	"walk_sprite":"WalkUnarmed",
	"attack_sprite":["AttackUnarmed"],
	"attack_index":0,
	#random on attack
	"random_sprite":false,
	"attack_sound":null,
	
	
	"kill_sprite":"",
	"kill_lean_sprite":"",
	
	"recoil":0,
	
	"droppable":false,
	#types:melee"
	"type":"melee",
	#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
	"attack_type":"downing",
	
	
	"execution_sprite":"ExecuteGround",
	"ground_sprite":"DieGround",
	"screen_shake":1,
	
	#trigger
	"trigger_pressed":false,
	"trigger_bullets":0,
	"trigger_reset":0.1,
	"trigger_shot":0,
	"shoot_bullets":0}
export var gun ={
	#id for hud
	"id":"Unarmed",
	#ammo of the gun
	"ammo":0,
	"max_ammo":0,
	# wad sprites
	"walk_sprite":"WalkUnarmed",
	"attack_sprite":["AttackUnarmed"],
	"attack_index":0,
	#random on attack
	"random_sprite":false,
	
	"attack_sound":null,
	
	"kill_sprite":"",
	"kill_lean_sprite":"",
	
	"recoil":0,
	
	"droppable":false,
	#types:melee"
	"type":"melee",
	#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
	"attack_type":"downing",
	
	
	"execution_sprite":"",
	"ground_sprite":"",
	"gun_length":0,
	"screen_shake":1,
	
	#trigger
	"trigger_pressed":false,
	"trigger_bullets":0,
	"trigger_reset":0.1,
	"trigger_shot":0,
	"shoot_bullets":0}
var given_height=0
var added_recoil = 0.0 #multiply this shit in the attack if needed
var closest_gun = null


#DOWNED STATE/EXECUTION STATE
export var MAX_GET_UP_TIME=8
export var down_timer=8
var in_distance_to_execute=false
var execute_target=null
export var execute_click=false
var can_get_up=true


#VISUALS AND MISC
export var shake_screen=false
var change_sprite_value=false
var change_leg_sprite_value=false
# Sprite variables
export var sprite_index = "WalkUnarmed"
export var leg_index = "WalkLegs"
var body_direction = 0

signal die


func _ready():
	gun=gun.duplicate(true)
	if get_node_or_null("TEMPSPRITE")!=null:
		get_node("TEMPSPRITE").queue_free()
	sprite_body.global_rotation=get_parent().global_rotation
	
	if sprite_index=="":
		_play_animation(gun.walk_sprite)
	sprite_legs.play(leg_index)
	
# Finds the first visible pickupable weapon dropped within 40 units of the player that isn't behind a wall 
func gun_finder():
	var dropped_weapons = get_tree().get_nodes_in_group("Weapon")
	var pickup_dist = 40*40
	
	for weapon in dropped_weapons:
		# filter weapons that cannot be picked up
		if weapon.pick_up == true && weapon.visible == true:
			# filter weapons within certain distance
			if weapon.global_position.distance_squared_to(sprites.global_position) < pickup_dist:
				# filter weapons behind walls
				get_node("PED_COL/weapon_find").cast_to = weapon.global_position - sprites.global_position
				if !get_node("PED_COL/weapon_find").is_colliding():
					closest_gun = weapon
					return weapon
	return null


func _process(delta):
	general_process(delta)


func _physics_process(delta):
	collision_body.global_rotation=0
	if gun.trigger_pressed==true:
		attack()
	if state == ped_states.down:
		movement()
#		axis=lerp(axis,Vector2.ZERO,0.1)
		if my_velocity.length()>0.1:
			axis=lerp(axis,Vector2.ZERO,10*delta)
			var test_motion=collision_body.move_and_collide(Vector2(16,0).rotated(my_velocity.angle()),false,true,true)
			if test_motion:
				my_velocity=Vector2.ZERO
				axis=Vector2.ZERO
				sprite_legs.play("GetUpLean")
				sprite_legs.global_rotation=test_motion.normal.angle()
				sprite_legs.speed_scale=0
				collision_body.global_position=test_motion.position
		if my_velocity.length()<5:
			sprite_body.global_rotation=sprite_legs.global_rotation
			if can_get_up==true:
				down_timer-=delta
				if down_timer<0:
					sprite_legs.speed_scale=1
	elif state == ped_states.dead:
		get_node("PED_COL/CollsionCircle").disabled=true
		if get_groups().size()>0:
			for i in get_groups():
				remove_from_group(i)
		if collision_body.get_groups().size()>0:
			for i in collision_body.get_groups():
				collision_body.remove_from_group(i)

func movement(new_motion=null,_delta=null):
	if new_motion==null:
		#normal movement code
		if axis.length() > 0:
			my_velocity=my_velocity.linear_interpolate(axis*MAX_SPEED,ACCELERATION)
			my_velocity= my_velocity.clamped(MAX_SPEED)
		else:
			pass
			my_velocity=my_velocity.linear_interpolate(Vector2(0,0),ACCELERATION*1.1)
	else:
		my_velocity=new_motion
	my_velocity=collision_body.move_and_slide(my_velocity)

func general_process(delta):
	if state==ped_states.alive:
		#pisss
		if delay>0:
			delay-=delta
			delay=clamp(delay,0,999)
		
		#use this shit idkgfdsfhbsdh
		if added_recoil>0:
			added_recoil=clamp(added_recoil,0,1.4)
			added_recoil-=delta
		else:
			added_recoil=0
		
		
		leg_sprites(delta)
		var body_sprite = sprite_body
		var walking = (gun.walk_sprite in sprite_index)
		
		if walking:
			body_sprite.speed_scale = (abs(my_velocity.length()/220))
		else:
			body_sprite.speed_scale = 1
		
		if body_sprite.animation != sprite_index:
			body_sprite.play(sprite_index,0,false,true)
			
		
	



func leg_sprites(delta):
	if (abs(my_velocity.length()))<20:
			sprite_legs.get_node("AnimationPlayer").seek(0)
	else:
		sprite_legs.rotation=lerp_angle(sprite_legs.rotation,atan2(my_velocity.y,my_velocity.x),50*delta)
		sprite_legs.speed_scale = (abs(my_velocity.length()/220))


#This script functions by reading through the poperty list of the gun variable and spawning
#a bullet depending on what the parameters are
#as well as doing melee initalization
func attack():
	# wad(NOT) integration
	var attack_sprite = "attack_sprite"
	if gun.type=="melee" && delay==0:
		# animation decision tree
		var chosen_attack_sprite = gun[attack_sprite][gun.attack_index]
		if sprite_index != attack_sprite:
			if gun.random_sprite == false:
				gun.attack_index = (gun.attack_index + 1) % gun[attack_sprite].size()
			else:
				gun.attack_index=rand_range(0,gun[attack_sprite].size()-1)
			delay=gun.trigger_reset
			sprite_index=chosen_attack_sprite
	elif gun.type=="semi" && delay==0 && gun.ammo>0:
		spawn_bullet(gun.shoot_bullets)
		# animation decision tree
		var chosen_attack_sprite = gun[attack_sprite][gun.attack_index]
		sprite_index=chosen_attack_sprite
		delay=gun.trigger_reset
		gun.trigger_pressed=false
	elif gun.type=="auto" && delay==0 && gun.ammo>0:
		spawn_bullet(gun.shoot_bullets)
		# animation decision tree
		var chosen_attack_sprite = gun[attack_sprite][gun.attack_index]
		sprite_index=chosen_attack_sprite
		sprite_body.set_frame(1,0)
		if gun.random_sprite == false:
			gun.attack_index = (gun.attack_index + 1) % gun[attack_sprite].size()
		else:
			gun.attack_index=rand_range(0,gun[attack_sprite].size()-1)
		delay=gun.trigger_reset
	elif gun.type=="burst" && gun.ammo>0:
		if gun.trigger_shot==0:
			gun.trigger_shot=gun.trigger_bullets
		for i in gun.trigger_shot:
			if delay==0 && gun.ammo>0:
				spawn_bullet(gun.shoot_bullets)
				# animation decision tree
				var chosen_attack_sprite = gun[attack_sprite][gun.attack_index]
				sprite_index=chosen_attack_sprite
				sprite_body.set_frame(1,0)
				if gun.random_sprite == false:
					gun.attack_index = (gun.attack_index + 1) % gun[attack_sprite].size()
				else:
					gun.attack_index=rand_range(0,gun[attack_sprite].size()-1)
				gun.trigger_shot-=1
				delay=gun.trigger_reset
				if gun.trigger_shot==0:
					gun.trigger_pressed=false
					delay=gun.trigger_reset*3.5
				



func switch_weapon():
	if sprite_index!=gun.attack_sprite[gun.attack_index] && delay==0:
		if !gun.id=="Unarmed Cutscene":
			drop_weapon()
			closest_gun = gun_finder()
			if closest_gun != null:
				var sound_pos=collision_body.global_position
				if get_class()=="Player":
					sound_pos=null
				AudioManager.play_audio("res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_PickupWeapon.wav",sound_pos,true,1,0,"Master")
				gun=dupe_dict(closest_gun.gun)
				closest_gun.call_deferred("queue_free")
	#			play_sample("res://Assets/Sounds/Weapons/Pick up/Pick_up.wav",0)
		sprite_index = gun.walk_sprite
#gun transfer script
func dupe_dict(fromdict):
	var todict=fromdict.duplicate(true)
	return todict


func drop_weapon(throw_speed=1,dir=null):
	if gun.droppable==true:
		var load_weapon=load("res://Data/DEFAULT/ENTS/ENT_GENERIC_WEAPON.tscn")
		var inst_weapon=load_weapon.instance()
		if dir==null:
			inst_weapon.linear_velocity=(Vector2(1200,0).rotated(body_direction))*throw_speed
		else:
			inst_weapon.linear_velocity=(Vector2(1200,0).rotated(dir))*throw_speed
		inst_weapon.global_position=collision_body.global_position+Vector2(15,0).rotated(body_direction)
		inst_weapon.gun=dupe_dict(gun)
		get_parent().call_deferred("add_child",inst_weapon)
		gun=dupe_dict(default_gun)
		gun.execution_sprite=""
		gun.ground_sprite=""
		var sound_pos=collision_body.global_position
		if get_class()=="Player":
			sound_pos=null
		AudioManager.play_audio("res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_Throw.wav",sound_pos,true,1,0,"Master")


func spawn_bullet(amoumt:int):
#	print(gun.random_attack_sounds)
	if gun.attack_sound!=null:
		AudioManager.play_audio(gun.attack_sound)
	if shake_screen==true:
		get_tree().get_nodes_in_group("Camera")[0].shake=gun.screen_shake
		Input.start_joy_vibration(0,1,1,1)
	gun.ammo-=1
	for i in amoumt:
		if gun.attack_type!="grenade":
			var sus_bullet=def_bullet_ent.instance()
			#add da weapon spawn bullet
			sus_bullet.global_position=collision_body.global_position+Vector2(24,0).rotated(body_direction)
			var recoil_add=body_direction
			if gun.has("recoil"):
				recoil_add+=deg2rad(rand_range(-gun.recoil,gun.recoil))
			sus_bullet.global_rotation=recoil_add
			if gun.attack_type=="normal":
				sus_bullet.penetrate=false
			get_parent().add_child(sus_bullet)
			if gun.has("kill_sprite"):
				sus_bullet.death_sprite=gun.kill_sprite
				sus_bullet.death_lean_sprite=gun.kill_lean_sprite
		else:
			var sus_bullet=def_grenade_ent.instance()
			#add da weapon spawn bullet
			sus_bullet.global_position=collision_body.global_position+Vector2(24,0).rotated(body_direction)
			var recoil_add=body_direction
			if gun.has("recoil"):
				recoil_add+=deg2rad(rand_range(-gun.recoil,gun.recoil))
			sus_bullet.global_rotation=recoil_add
			sus_bullet.height=clamp(given_height,1,1000)
			get_parent().add_child(sus_bullet)
	pass


func move_to_point(delta,point:Vector2,speed=0.7):
	if get_node("PED_COL/movement_check").is_colliding()==false:
		#cum calculation piss =focused_player.global_position+Vector2(25,0).rotated(focused_player.global_position.direction_to(collision_body.global_position).angle())
		axis=lerp(axis,Vector2(speed,0).rotated(collision_body.global_position.direction_to(point).angle()),50*delta)
		body_direction=lerp_angle(body_direction,axis.angle(),0.15)
	else:
		navigate_to_point(point)
		var temp_dir=Vector2(0,0)
		if path.size()>1:
			if collision_body.global_position.distance_to(path[-1])<5:
				path.remove(path.size()-1)
			temp_dir=collision_body.global_position.direction_to(path[-1])
		axis=temp_dir*speed
	movement()


func navigate_to_point(point):
	path = get_tree().get_nodes_in_group("NavMap")[0].get_astar_path(point,collision_body.global_position)

func _on_Legs_animation_finished():
	change_leg_sprite_value=true

func _play_animation(animation:String,frame=0):
	sprite_body.seek(frame,true)
	sprite_index = animation

func do_remove_health(damage=1,killsprite:String="DeadBlunt",rot:float=randi(),frame="rand",body_speed=2,_bleed=false):
	var damage_output
	if damage is Array:
		damage_output=rand_range(damage[0],damage[1])
	else:
		damage_output=damage
	health-=damage_output
	if state==ped_states.alive or (state == ped_states.down && "Lean" in sprite_legs.animation):
		if health<=0:
			drop_weapon(randf()*0.3,randi())
			sprite_legs.play(killsprite)
			if frame=="rand":
				sprite_legs.seek(rand_range(0,sprite_legs.get_node("AnimationPlayer").current_animation_length))
			else:
				sprite_legs.seek(frame)
			sprite_legs.global_rotation=rot
			sprite_legs.speed_scale=0
			sprite_body.visible=false
			state=ped_states.dead

func go_down(direction=randi()):
	if state == ped_states.alive:
		if sprite_legs.has_animation("GetUp"):
			drop_weapon(0.1)
			state = ped_states.down
			sprite_legs.play("GetUp",0,false,0)
			sprite_legs.speed_scale=0
			sprite_legs.global_rotation_degrees=rad2deg(direction)+180
			sprite_body.visible=false
			down_timer=8
			collision_body.set_collision_layer_bit(6,false)
			axis=Vector2(0.8,0).rotated(direction)
#		collision_body.linear_damp=6




func get_up():
	state=ped_states.alive
	sprite_body.visible=true
	get_node("PED_SPRITES/Body/Melee_Area/CollisionShape2D").disabled=true


func do_execution():
	if get_downed_enemies() != null:
		state=ped_states.execute
		axis=Vector2(0,0)
		my_velocity=Vector2(0,0)
		execute_target.get_parent().my_velocity=Vector2(0,0)
		execute_target.get_parent().axis=Vector2(0,0)
		collision_body.global_position=execute_target.global_position
		sprite_body.global_rotation=execute_target.get_parent().sprite_legs.global_rotation-deg2rad(180)
		
		if execute_target.get_parent().sprite_legs.animation!="GetUpLean":
			if gun.execution_sprite!="":
				sprite_body.play(gun.execution_sprite)
				execute_target.get_parent().sprite_legs.play(gun.ground_sprite,0,false,0)
			else:
				drop_weapon(0.1,deg2rad(rand_range(-180,180)))
				sprite_body.play(default_gun.execution_sprite)
				execute_target.get_parent().sprite_legs.play(default_gun.ground_sprite,0,false,0)
		else:
				sprite_body.play("ExecuteWall")
				execute_target.get_parent().sprite_legs.play("DieLean")
		
		sprite_legs.visible=false
		execute_target.get_parent().can_get_up=false





func get_downed_enemies():
	var ground_enemies = get_tree().get_nodes_in_group("PED")
	in_distance_to_execute = false
	var pickup_dist = 40*40
	
	for enemy in ground_enemies:
		# filter enemies that cannot be executed
		if enemy.get_parent().state == ped_states.down && enemy.visible == true:
			# filter weapons within certain distance
			if enemy.global_position.distance_squared_to(sprites.global_position) < pickup_dist:
				# filter weapons behind walls
				
				get_node("PED_COL/weapon_find").cast_to = enemy.global_position - sprites.global_position
				if !get_node("PED_COL/weapon_find").is_colliding():
					in_distance_to_execute=true
					execute_target = enemy
					return enemy
	return null




func execute_remove_health(damage=1,ammo_use=0,animation="",frame="rand",sound=null,_bleed:bool=false):
	if state==ped_states.execute:
		var par=execute_target.get_parent()
		var damage_output
		if damage is Array:
			damage_output=rand_range(damage[0],damage[1])
		else:
			damage_output=damage
		if ammo_use>0:
			var usable_ammo=clamp(gun.ammo,1,ammo_use)
			gun.ammo-=1
			damage_output=clamp(par.health,1,999)/usable_ammo
		par.health-=damage_output
		if par.health<=0:
			if sound!=null:
				AudioManager.play_audio(sound)
			par.state=ped_states.dead
			if animation!="":
				par.sprite_legs.play(animation,0,false,0)
				if frame=="rand":
					par.sprite_legs.seek(rand_range(0,sprite_legs.get_node("AnimationPlayer").current_animation_length))
				else:
					par.sprite_legs.seek(frame)
			state=ped_states.alive
			sprite_legs.visible=true
			sprite_index=gun.walk_sprite
			delay=0.1
			return true


#go to the next enemy sprite frame
func execute_e_next_frame(frame_rate:int = 13):
	execute_target.get_parent().sprite_legs.next_frame(frame_rate)
	return true #output if command was completed

func execute_e_copy_time():
	execute_target.get_parent().sprite_legs.seek(sprite_body.frame)

#read the function
func execute_do_click():
	sprite_body.speed_scale=1


func get_class():
	return "PED"


#used for gun flipping 
static func angle_difference(from, to):
	return fposmod(to-from + PI, PI*2) - PI
