extends RigidBody2D


class_name WEAPON

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pick_up=false
var wait_pickup=0.001

@onready var sprite=get_node("SPRITE")
@onready var col=get_node("CollisionShape2D")

@export var gun={
	#id for hud
	"id":"M16",
	#ammo of the gun
	"max_ammo":30,
	"ammo":25,
	# wad sprites
	"attack_count":1,
	"attack_index":0,
	#random on attack
	"random_sprite":false,
	#flip on attack
	"flip_sprite":false,

	"sound_index":0,
	"random_attack_sounds":true,
	"random_kill_sounds":true,
	
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
	sprite.global_rotation=global_rotation
	sprite.animation=gun["id"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.global_position=global_position
	sprite.global_rotation+=deg_to_rad(linear_velocity.length()*5*delta)
	if wait_pickup>0 && pick_up==false:
		wait_pickup-=delta
	else:
		pick_up=true
	if linear_velocity.length()<50:
		col.disabled=true


func _manual_visiblity(input1=true):
	sprite.visible=input1


func _on_ENT_GENERIC_WEAPON_body_entered(body):
	if body in get_tree().get_nodes_in_group("Enemy") && col.disabled==false:
		body.get_parent().go_down(global_position.direction_to(body.global_position).angle())
		pass


