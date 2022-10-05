extends RigidBody2D


class_name WEAPON

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pick_up=false
var wait_pickup=0.001


@export var gun={
	#id for hud
	"id":"M16",
	#ammo of the gun
	"max_ammo":30,
	"ammo":25,
	# wad sprites
	"walk_sprite":"WalkM16",
	"attack_sprite":["AttackM16"],
	"attack_index":0,
	#random checked attack
	"random_sprite":false,
	#flip checked attack
	"flip_sprite":false,

	"sound_index":0,
	"random_attack_sounds":true,
	"attack_sound":["sndM16"],
	"random_kill_sounds":true,
	"kill_sound":[],
	
	"kill_sprite":"DeadMachinegun",
	"kill_lean_sprite":"DeadLeanMachinegun",
	
	"execution_sprite":[],
	
	"recoil":4,
	
	"pitch_change":0.1,
	"screen_shake":35,
	
	"droppable":true,
	#types:melee,burst,semi,auto
	"type":"semi",
	#attack_type:| normal, armor, grenade
	"attack_type":"normal",
	"gun_length":24,
	#trigger
	"trigger_pressed":false,
	"trigger_bullets":3,
	"trigger_reset":0.08,
	"trigger_shot":0,
	"shoot_bullets":1
}



func _ready():
	get_node("SPRITE").global=global_rotation
#	_create_collision_polygon(get_node("SPRITE").texture,l[2])
#	print(l[0].get_data())
#	var dick= AtlasTexture.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("SPRITE").global_position=global_position
	get_node("SPRITE").global_rotation_degrees+=linear_velocity.length()*5*delta
	if wait_pickup>0 && pick_up==false:
		wait_pickup-=delta
	else:
		pick_up=true
	if linear_velocity.length()<50:
		get_node("CollisionShape2D").disabled=true


func _manual_visiblity(input1=true):
	get_node("SPRITE").visible=input1


func _on_ENT_GENERIC_WEAPON_body_entered(body):
	if body in get_tree().get_nodes_in_group("Enemy") && get_node("CollisionShape2D").disabled==false:
		body.get_parent().go_down(global_position.direction_to(body.global_position).angle())
		pass


