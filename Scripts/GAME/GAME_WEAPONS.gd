extends Node

var glob_delta=0
var glob_phys_delta=0

const weapon_database={
	"Unarmed":{
		#id for hud
		"id":"Unarmed",
		# ammount of attack sprites counting from 0
		"attack_count":0,
		# which attack is used depending on the count
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
		
		
		"execution_sprite":"Execute",
		"ground_sprite":"DieGround",
		
		#trigger
		"trigger_pressed":false,
		"trigger_reset":0.1,
	}
	,
	"Knife":{
		#id for hud
		"id":"Knife",
		#ammo of the gun
		"max_ammo":6,
		# wad sprites
		"attack_count":0,
		"attack_index":0,
		#random on attack
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
		
		
		"execution_sprite":"Knife",
		"ground_sprite":"DieKnife",
		"gun_length":0,
		"screen_shake":1,
		
		#trigger
		"trigger_reset":0.1,
		"trigger_pressed":false,
	}
	,
	"Bat":{
		#id for hud
		"id":"Bat",
		# wad sprites
		"walk_sprite":"Walk",
		"attack_sprite":["Attack"],
		"attack_index":0,
		#random on attack
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
		
		
		"execution_sprite":"Bat",
		"ground_sprite":"DieBat",
		"gun_length":0,
		"screen_shake":1,
		
		#trigger
		"trigger_reset":0.1,
		"trigger_pressed":false,
	}
	,
	"M9":{
		"id":"M9",
		#ammo of the gun
		"ammo":17,
		"max_ammo":17,
		"reserve":[17,17,17],
		
		# wad sprites
		"walk_sprite":"Walk",
		
		"turn_right":"Turn_Right",
		"turn_left":"Turn_Left",
#		"walk_sprite_empty":"WalkJ941R_Empty",
		
#		"holster":"HolsterJ941R",
#		"unholster":"UnHolsterJ941R",
		
#		"holster_empty":"HolsterJ941R_Empty",
#		"unholster_empty":"UnHolsterJ941R_Empty",
		
		"attack_sprite":["Attack"],
#		"attack_sprite_empty":["AttackJ941R_Empty"],
		
		
		"attack_index":0,
		#random on attack
		"random_sprite":false,
		"attack_sound":"res://Data/Sounds/Maxim 9/Fire.wav",
		"damage":75,
		"added_recoil":0.2,
		"recoil":4,
		
		"kill_sprite":"DeadMachinegun",
		"kill_lean_sprite":"DeadLeanMachinegun",
		
		
		"ring_ammount":0.09,
		"hearing_radius":220,
		"smoke_timer":5.0,
		
		"droppable":true,
		#types:melee,burst,semi,auto
		"type":"semi",
		#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
		"attack_type":"normal",
		
		
		"execution_sprite":"Execute",
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
	,
	"M16":{
		#id for hud
		"id":"M16",
		#ammo of the gun
		"ammo":30,
		"max_ammo":30,
		"reserve":[30,30,30],
		# wad sprites
		"walk_sprite":"Walk",
		"attack_sprite":["Attack"],
		"attack_index":0,
		#random on attack
		"random_sprite":false,
		"attack_sound":"res://Data/Sounds/Vector/Fire.wav",
		"dry_fire":"PED_SPRITES/Body/Sound Library/AR-57/Trigger Pressed",
		
		"damage":75,
		"added_recoil":0.1,
		"recoil":4,
		
		
		"kill_sprite":"DeadMachinegun",
		"kill_lean_sprite":"DeadLeanMachinegun",
		
		
		"ring_ammount":0.2,
		"hearing_radius":160,
		
		
		"droppable":true,
		#types:melee,burst,semi,auto
		"type":"auto",
		#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
		"attack_type":"armor",
		
		
		"execution_sprite":"",
		"ground_sprite":"",
		"screen_shake":1,
		
		
		#trigger
		"trigger_pressed":false,
		"trigger_bullets":0,
		"trigger_reset":0.055,
		"trigger_shot":0,
		"shoot_bullets":1
	}
	,
	"Shotgun":{
		#id for hud
		"id":"Shotgun",
		#ammo of the gun
		"ammo":7,
		"max_ammo":6,
		# wad sprites
		"walk_sprite":"Walk",
		"attack_sprite":["Attack"],
		"attack_index":0,
		#random on attack
		"random_sprite":false,
		"damage":75,
		
		
		"kill_sprite":"DeadShotgun",
		"kill_lean_sprite":"DeadLeanShotgun",
		
		"recoil":8,
		
		"droppable":true,
		#types:melee,burst,semi,auto
		"type":"semi",
		#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
		"attack_type":"armor",
		
		
		"execution_sprite":"Execute",
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
}

func get_wep(input_weapon):
	return weapon_database[input_weapon].duplicate(true)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	glob_delta=delta

func _physics_process(delta):
	glob_phys_delta=delta
