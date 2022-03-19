extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var random_timer=rand_range(0,1)



# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	random_timer-=delta
#	if random_timer<0:
#		spawn_eneny()


func spawn_eneny():
	var eneny=load("res://Data/DEFAULT/ENTS/PED_ENEMY.tscn").instance()
	get_parent().add_child(eneny)
	eneny.global_position=global_position
	eneny.get_node('PED_SPRITES').teleport()
	var gun=debug_rand_weapon()
	eneny.gun=gun
	eneny.sprite_index=gun.walk_sprite
	random_timer=rand_range(10,15)

func debug_rand_weapon():
			var random_weapon=int(round(rand_range(0,3)))
			var gun
			match random_weapon:
				0:#M16
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
						#random on attack
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
						#random on attack
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
				2:#UZI
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
						#random on attack
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
						#random on attack
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
				4:#Knife
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
						#random on attack
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
			return gun


func dupe_dict(fromdict):
	var todict=fromdict.duplicate(true)
	return todict
