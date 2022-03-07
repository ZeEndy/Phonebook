extends KinematicBody2D

#const impact = preload("res://Weapons/Effects/Impact.tscn")
var bullet
var paused=false
var speed = 3750
export var velocity = Vector2()
export var force=0
var get_destroyed=true
var last_position=Vector2()
var hit_point=Vector2()
var hit_rotation =0 
var height=0

func _ready():
	speed = 1000+rand_range(-150,150)



func _physics_process(delta):
	modulate = Color.white.linear_interpolate(Color.yellow, randf())
	velocity = Vector2(speed, 0).rotated(rotation)
	height-=10*delta
#	get_node("Sprite_Bullet").scale.x=lerp(get_node("Sprite_Bullet").scale.x,1,0.3*delta*60)
	var collision = move_and_collide(velocity*delta,false)
	if collision or height<=0:
		explode()

func explode():
	#wad audio
#	play_audio("Sounds/sndBigExplosion")
	var peds = get_node("Area2D").get_overlapping_bodies()
	get_tree().get_nodes_in_group("Camera")[0].shake=360
	
	#big splat
	#THERE WAS WAD CODE THAT HAS BEEN REMOVED
	#ADD YOUR OWN EFFECTS IN THIS SCRIPT
	
	#get_parent().get_node_or_null(get_parent().my_surface).add_to_surface(sprite.get_path(),sprite.global_position,sprite.global_rotation)
	
#	for i in 30:
#		spawn_explode_particle(explode_frames)
#	for i in rand_range(30,60):
#		spawn_explode_debri_particle(explode_frames)
	for ped in peds:
		if ped.get_parent().has_method("do_remove_health"):
			if ped.get_parent().get_parent().visible == true:
				get_node("ped_find").cast_to = ped.global_position - global_position
				if !get_node("ped_find").is_colliding():
					ped.get_parent().do_remove_health(10,"DeadExplosion",(ped.global_position.angle_to_point(global_position)))
		else:
			continue

	queue_free()





func spawn_explode_particle(frames=null):
#	var sprite = WadSprite.new()
#	sprite.frames=frames
#	sprite.animation="sprFlameSmoke"
#	sprite.playing=true
#	sprite.set_script(load("res://Scripts/VFX/Grenade Impact/VFX_Explode.gd"))
#	sprite.direction=deg2rad(randi())
#	sprite.global_position=global_position
#	sprite.speed=10+rand_range(10,30)
#	sprite.friction=0.01+rand_range(0,3)
#	get_parent().add_child(sprite)
	pass

func spawn_explode_debri_particle(frames=null):
#	var sprite = WadSprite.new()
#	sprite.frames=frames
#	sprite.set_script(load("res://Scripts/VFX/Grenade Impact/VFX_Debri.gd"))
#	var given_anim=int(rand_range(0,4))
#	sprite.modulate=Color(0.05,0.05,0.05)
#	match given_anim:
#		0:
#			sprite.animation="sprSmudge3"
#			sprite.friction=rand_range(0.1,1)
#		1:
#			sprite.animation="sprSmudge3Red"
#			sprite.friction=rand_range(0.1,1)
#		2:
#			sprite.animation="sprBigBlood1"
#			sprite.friction=rand_range(2,10)
#		3:
#			sprite.animation="sprBigBlood2"
#			sprite.friction=rand_range(2,10)
#		4:
#			sprite.animation="sprWaterPool"
#			sprite.friction=10
#			sprite.modulate=Color(0,0,0)
#			sprite.frame=rand_range(17,23)
#	sprite.playing=true
#
#	sprite.direction=deg2rad(randi())
#	sprite.global_position=global_position
#	sprite.speed=10+rand_range(0,20)
#
#	get_parent().add_child(sprite)
	pass

