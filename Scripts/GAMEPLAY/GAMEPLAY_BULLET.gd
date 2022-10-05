extends Sprite2D

class_name BULLET
#const impact = preload("res://Weapons/Effects/Impact.tscn")
var bullet
var paused=false
var speed = 3750
@export var velocity = Vector2()
@export var size = Vector2(8,1)
@export var force=0
var get_destroyed=true
var penetrate=true
var last_position=Vector2()
var hit_point=Vector2()
var hit_rotation =0 
var _wad=null
var damage=1
var signal_=""
signal bullet_signal
var ground_hole=""
var kill=false


var bullet_height=20
var death_sprite=""
var death_lean_sprite=""

func _ready():
	speed = 1000+randf_range(-150,150)




func _physics_process(delta):
	var collision = check_collision()
	if collision.size()>0:
		if collision[0].collider.get_parent().has_method("do_remove_health"):
#			spawn_smoke(collision.normal.angle(),collision.position,Color.RED,0)
			if penetrate==true:
#				var exit_wound_pos = collision[0].collider.global_position+(Vector2(collision.collider.global_position.distance_to(collision[0].position),0).rotated((collision.collider.global_position-collision.position).angle()))
#				spawn_smoke(-collision.normal.angle(),exit_wound_pos,Color.RED,0)
				get_destroyed=false
			else:
				get_destroyed=false
				queue_free()
			#fuck me this is stupid
			if kill==false:
				if "Lean" in collision[0].collider.get_parent().sprites.get_node("Legs").animation:
					if signal_!="":
						emit_signal("bullet_signal")
					collision[0].collider.get_parent().do_remove_health(damage,death_lean_sprite,collision[0].collider.get_parent().sprites.get_node("Legs").global_rotation,"rand",-0.1)
				else:
					if signal_!="":
						emit_signal("bullet_signal")
					collision[0].collider.get_parent().do_remove_health(damage,death_sprite,global_rotation)
				kill=true
		elif collision[0].collider.get_parent().has_method("destroy_window"):
			collision[0].collider.get_parent().destroy_window()
			
		else:
#			hit_point=collision[0].collider.position
#			hit_rotation=collision[1].normal.angle()
			destroy()
	else:
		kill=false
		get_destroyed=true
	if (bullet_height<0):
		if ground_hole!="":
			var frames=SpriteFrames.new()
			var sprite=AnimatedSprite2D.new()
			frames.add_frame("default",load(ground_hole))
			sprite.frames=frames
			add_child(sprite)
			get_parent().get_node_or_null(get_parent().my_surface).add_to_surface(sprite,global_position,deg_to_rad(randf_range(-180,180)))
		spawn_smoke(global_rotation-PI,global_position,Color.WHITE_SMOKE,1)
		for i in 7+randf_range(0,12):
			spawn_spark(rad_to_deg(randf_range(0,PI*2)),global_position)
		queue_free()
		return
	bullet_height-=delta
	modulate = Color.WHITE.lerp(Color.YELLOW, randf())
	velocity = Vector2(speed, 0).rotated(rotation)
#	get_node("Sprite_Bullet").scale.x=lerp(get_node("Sprite_Bullet").scale.x,1,0.3*delta*60)
	global_position+=(velocity*delta)


func destroy():
	spawn_smoke(hit_rotation,hit_point,Color.WHITE_SMOKE,1)
	for i in 4+randf_range(0,6):
		spawn_spark(rad_to_deg(hit_rotation),hit_point)
	queue_free()

func spawn_spark(given_dir=global_rotation,given_pos=global_position):
#	var sprite = WadSprite.new()
#	sprite.frames=_wad.meta_sprite("Atlases/TinySpritesAtlas.meta")
#	sprite.animation="sprSpark"
#	sprite.set_script(load("res://Scripts/VFX/Bullet impact/VFX_Spark.gd"))
#	var my_material = CanvasItemMaterial.new()
#	my_material.set("blend_mode",BLEND_MODE_ADD)
#	sprite.material=my_material
#	var dir =given_dir+randf_range(-65,65)
#	sprite.global_rotation_degrees=dir
#	sprite.direction=dir
#	sprite.global_position=given_pos
#	sprite.speed=2+randf_range(0,5)*randf()
#	get_parent().add_child(sprite)
	pass

func spawn_smoke(given_dir=global_rotation,given_pos=global_position,given_color=Color.WHITE_SMOKE,random=1):
#	var sprite = WadSprite.new()
#	sprite.frames=_wad.meta_sprite("Atlases/Sprites/Effects/Smoke/sprSmokeHit.meta")
#	sprite.animation="sprSmokeHit"
#	sprite.playing=true
#	sprite.set_script(load("res://Scripts/VFX/Bullet impact/VFX_Smoke_hit.gd"))
##	var my_mat3erial = CanvasItemMaterial.new()
##	my_material.set("blend_mode",BLEND_MODE_ADD)
#	sprite.modulate=given_color
##	sprite.material=my_material
#	sprite.direction=given_dir+deg_to_rad(randf_range(-65,65)*random)
#	sprite.global_position=given_pos
#	sprite.speed=1+randf_range(0,0.5)*randf()
#	get_parent().add_child(sprite)
	pass



func check_collision():
	var collision_objects=[]
	
	var shape = RectangleShape2D.new()
	shape.extents=size
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.collision_layer=61
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(global_rotation, global_position+shape.extents.rotated(global_rotation)))
	var piss=space.intersect_shape(query,1)
	if piss.size()>0:
		collision_objects=[piss[0],space.get_rest_info(query)]
	return collision_objects



func play_sample(given_sample,affected_time=true,true_pitch=1,random_pitch=0,bus="Master"):
#	print(given_sample)
#	if (given_sample is String):
#		var audio_player := AudioStreamPlayer.new()
#		audio_player.stream = _wad.audio_stream(given_sample+".wav",true)
#		#gonna add this script later but gonna need to probably rethink about that
#		audio_player.set_script(load("res://Scripts/AUDIO/AUDIO_STREAM_SOUND.gd"))
#		audio_player.affected_time=affected_time
#		get_parent().get_parent().call_deferred("add_child",audio_player)
#		audio_player.current_pitch=true_pitch+randf_range(-random_pitch,random_pitch)
#		audio_player.autoplay = true
#		audio_player.set_bus(bus) 
#	elif given_sample is Array:
#		if (typeof(given_sample[0])==1 && given_sample[0]==false):
#			print("type of is 1")
#			play_sample(given_sample[randf_range(1,given_sample.size()-1)],affected_time,true_pitch,random_pitch,bus)
#		else:
#			for i in given_sample:
#				play_sample(i,affected_time,true_pitch,random_pitch,bus)
	return true
