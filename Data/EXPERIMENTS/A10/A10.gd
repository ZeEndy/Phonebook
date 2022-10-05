extends Node2D

@onready var a10_bullet=preload("res://Data/EXPERIMENTS/A10/A10_BULLET.tscn")
var bullets=randf_range(120,160)
var list_of_bullets
var climb=bullets
var spawn_bullet_timer=0
var kill_comfirmed=false

@onready var a10_node=get_node("a10")
var played_fly_by=false
var played_funny=false
var played_confirm=false

func _ready():
	if get_tree().get_nodes_in_group("EXPERIMENT_A10").size()>1:
		queue_free()
	get_node("incoming_confirm").play()


func _process(delta):
	get_node("a10/fly_by").pitch_scale=Engine.time_scale
	get_node("incoming_confirm").pitch_scale=Engine.time_scale
	get_node("wrath_of_god").pitch_scale=Engine.time_scale
	get_node("ground_impact").pitch_scale=Engine.time_scale
	if get_node("incoming_confirm").playing!=true:
		a10_node.position.x+=3000*delta
		if played_fly_by!=true:
			if get_node("a10/fly_by").playing!=true:
				get_node("a10/fly_by").play()
				played_fly_by=true
				print(get_node("a10/bullet_cache").get_child_count())
		if a10_node.position.x>-1000:
			if bullets>0:
				if get_node("ground_impact").playing==false:
					get_node("ground_impact").play()
				if spawn_bullet_timer<=0:
					get_tree().get_nodes_in_group("Camera3D")[0].shake=30
					var bullet_instance=get_node("a10/bullet_cache").get_child(bullets-1)
					get_node("a10/bullet_cache").remove_child(bullet_instance)
					get_parent().add_child(bullet_instance)
					bullet_instance.global_position=global_position+Vector2(a10_node.position.x+300+(climb-bullets)*10,randf_range(-100,100)).rotated(global_rotation)
					bullet_instance.speed=2200
					bullet_instance.bullet_height=0.05+(climb-bullets)*0.003
					bullet_instance.global_rotation=global_rotation+deg_to_rad(randf_range(-5,5))
					bullet_instance.death_sprite="DeadShotgun"
					bullet_instance.death_lean_sprite="DeadLeanShotgun"
					bullet_instance.ground_hole="res://Data/EXPERIMENTS/A10/sprBulletHole.png"
					bullet_instance.signal_="a10"
#					bullet_instance.global_rotation=-(a10_node.global_position.direction_to(bullet_instance.global_position)).angle()
					get_node("ground_impact").global_position=bullet_instance.global_position
					spawn_bullet_timer=randf_range(2400/(60*60*60),2800/(60*60*60))
					get_node("wrath_of_god").global_position=a10_node.global_position+Vector2(1500,0).rotated(global_rotation)
					bullets-=1
					if bullets<=0:
						spawn_bullet_timer=randf_range(0.85,1)
				
				
			if bullets<0:
				if played_funny==false:
					if spawn_bullet_timer<=0:
						if get_node("wrath_of_god").playing==false:
							played_funny=true
							get_node("wrath_of_god").play()
				else:
					if get_node("wrath_of_god").playing==false:
						if played_confirm==false:
							played_confirm=true
				if played_confirm==true:
					queue_free()
	else:
		if bullets>=get_node("a10/bullet_cache").get_child_count():
			if spawn_bullet_timer<=0:
				var bullet_instance=a10_bullet.instantiate()
				bullet_instance.connect("bullet_signal",Callable(self,"confirm_kill"))
				get_node("a10/bullet_cache").add_child(bullet_instance)
				bullet_instance.speed=0
				bullet_instance.bullet_height=2000
				spawn_bullet_timer=0.0005
	spawn_bullet_timer-=delta


func confirm_kill():
	kill_comfirmed=true
