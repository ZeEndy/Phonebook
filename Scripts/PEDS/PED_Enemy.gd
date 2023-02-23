extends PED

class_name Enemy

#reference variables
@onready var visibilty_check=get_node("PED_COL/visibilty_check")
@onready var movement_check=get_node("PED_COL/movement_check")


#states
enum Enemy_t {
	RANDOM,
	PATROL,
	STATIONARY,
	DODGER,
	DOG_PATROL,
	FAT}

enum enemy_s {
	neutral,
	charging,
	aiming,
	chasing}

@export var enemy_type:Enemy_t
@export var enemy_state = enemy_s.neutral


#alert stuff
enum alert_s{
	normal,
	alert,
	ready}

@export var alert_state=alert_s.normal
@export var alert_timer=-1
var random_timer = 0

#misc
var spawn_timer=0.1
var target_point=Vector2.ZERO
var direction=0
var focused_player=null

func _ready():
#	get_node("pathline").global_position=Vector2(0,0)
#	get_node("pathline").global_rotation=0
	if alert_timer==-1:
		alert_timer=alert_time()
	enemy_state=-1

#func _process(_delta):
#	update()

func _physics_process(delta):
	#fuck you Juan and your fucking quircky engine
	if spawn_timer>-1: 
		spawn_timer-=delta 
		if spawn_timer<0:
			enemy_state=enemy_s.neutral
			spawn_timer=-1

	var delta_time=delta*60
	if get_tree().get_nodes_in_group("Player").size()>0:
		if focused_player==null:
			focused_player=get_tree().get_nodes_in_group("Player")[0]
		else:
			
			visibilty_check.target_position=focused_player.global_position-collision_body.global_position
			movement_check.target_position=focused_player.global_position-collision_body.global_position

	if state==ped_states.alive:
		if enemy_state==enemy_s.neutral:
			if player_visibilty()==true:
				if alert_timer<0:
					enemy_state=enemy_s.charging
					alert_timer=alert_time()
					alert_state=alert_s.ready
				else:
					alert_timer-=1*delta_time
			else:
				alert_timer=alert_time()
			if enemy_type==Enemy_t.PATROL:
				sprites.get_node("Body").global_rotation=body_direction
				movement(null,delta)
				axis=Vector2(0.20,0).rotated(deg_to_rad(direction))
				body_direction=lerp_angle(body_direction,axis.angle(),0.15)
				var v = Vector2(my_velocity.length()/2,0).rotated(deg_to_rad(direction))
				var shape = RectangleShape2D.new()
				shape.extents=Vector2(v.length(),get_node("PED_COL/CollsionCircle").shape.radius)
				var query = PhysicsShapeQueryParameters2D.new()
				query.set_shape(shape)
				query.collision_layer=32
				var space = get_world_2d().direct_space_state
				query.set_transform(Transform2D(deg_to_rad(direction),get_node("PED_COL").global_position+Vector2(shape.extents.x/2,0).rotated(deg_to_rad(direction))))
				query.exclude.append(get_node("PED_COL"))
				if space.intersect_shape(query,1).size()>0:
					direction -= 10 * delta_time
				else:
					var dif = fmod(direction, 90)
					if abs(dif) > 10 * delta_time:
						direction -= 10 * delta_time
					else:
						direction -= dif
			elif enemy_type==Enemy_t.RANDOM:
				sprites.get_node("Body").global_rotation=body_direction
				body_direction=lerp_angle(body_direction,deg_to_rad(direction),0.15)
				movement(null,delta)
				random_timer -= 1 * delta_time
				if (random_timer <= 0):
					direction = randi() % 360
					axis=Vector2((randi() % 2)*0.25,0).rotated(deg_to_rad(direction)) 
					print(axis)
					random_timer = 60 + (randi() % 61)
				var v = Vector2(12,0).rotated(deg_to_rad(direction))
				#this causes a masive memory leak. too bad
				#TODO: find a better way to bounce
				
				#EDIT: I doubt this causes a memory leak I think I might have been stupid
				#lol
				var c = get_node("PED_COL").move_and_collide(v, true, true, true)
				if c:
					v = v.bounce(c.get_normal())
					direction = rad_to_deg(v.angle())
					axis=Vector2(axis.length(),0).rotated(deg_to_rad(direction)) 
				return
			elif enemy_type==Enemy_t.STATIONARY:
				movement(Vector2(0,0),delta)
				return
		else:
			if get_tree().get_nodes_in_group("Player").size()>0:
				if enemy_state==enemy_s.charging:
					sprite_body.global_rotation=body_direction
					if enemy_type!=Enemy_t.DODGER && enemy_type!=Enemy_t.DOG_PATROL:
						if player_visibilty()==true:
							if gun.type!="melee":
								
								var clamped_rotation_speed=clamp(movement_check.target_position.length()*0.02,0.15,0.25)
								body_direction=lerp_angle(body_direction,movement_check.target_position.angle(),clamped_rotation_speed*60*delta)
								if alert_timer>0:
									alert_timer-=1*delta_time
								if movement_check.target_position.length()<280:
									if alert_timer<=0:
										attack()
									axis=Vector2(0,0)
									movement(null,delta)
								else:
									move_to_point(delta,focused_player.global_position,1.0)
								return
							elif gun.type=="melee":
								if movement_check.target_position.length()<24:
									body_direction=lerp_angle(body_direction,collision_body.global_position.direction_to(focused_player.global_position).angle(),0.25)
									attack()
									if focused_player.get_parent().state==ped_states.down:
										do_execution()
								if movement_check.target_position.length()>10:
									move_to_point(delta,focused_player.global_position,1.0)
								else:
									axis=lerp(axis,Vector2.ZERO,1.0)
									movement(null,delta)
								return
						else:
							enemy_state=enemy_s.chasing
							alert_state=alert_s.ready
							target_point=focused_player.global_position
							alert_timer=alert_time()
				elif enemy_state==enemy_s.chasing:
					sprite_body.global_rotation=body_direction
					body_direction=lerp_angle(body_direction,axis.angle(),0.25)
#					get_node("PED_COL/Label").text=String(path.size())
					move_to_point(delta,target_point)
					if player_visibilty()==true:
						if alert_timer<0:
							enemy_state=enemy_s.charging
							alert_state=alert_s.ready
							alert_timer=alert_time()
							return
						else:
							alert_timer-=1*delta_time
					if path.size()==1:
						axis=Vector2()
						enemy_state=enemy_s.neutral
						alert_state=alert_s.alert
						alert_timer=alert_time()
						path=[]
			else:
				enemy_state=enemy_s.neutral
	elif state==ped_states.down:
		body_direction=sprite_legs.global_rotation
		if sprite_legs.speed_scale==0:
			collision_body.set_collision_layer_value(7,false)
			CharacterBody2D
		else:
			collision_body.set_collision_layer_value(7,true)
		return
	elif state==ped_states.execute:
		if execute_click==true:
			sprite_body.speed_scale=1
			sprite_body.get_node("AnimationPlayer").playback_speed=1


func go_down(down_dir=randi()):
	if state == ped_states.alive:
		if sprite_body.frames.has_animation("GetUp"):
			collision_body.set_collision_layer_bit(0,false)
	super(down_dir)




func player_visibilty(mode=0):
	var seen=true
	if focused_player!=null:
		if mode==0:
			var shape = RectangleShape2D.new()
			shape.extents=Vector2(collision_body.global_position.distance_to(focused_player.global_position)/2,4)
			var query = PhysicsShapeQueryParameters2D.new()
			query.set_shape(shape)
			query.collision_mask=16
			var space = get_world_2d().direct_space_state
			var angle=collision_body.global_position.direction_to(focused_player.global_position).angle()
			query.set_transform(Transform2D(angle,collision_body.global_position+Vector2(shape.extents.x,0).rotated(angle)))
			if space.intersect_shape(query,1).size()>0 || focused_player.get_parent().get_parent()!=get_parent():
				seen=false
		#add other modes like cone and shit here
	else:
		seen=false
	return seen



func alert_time():
	match alert_state:
		alert_s.normal:
			return 10
		alert_s.alert:
			return 7.5
		alert_s.ready:
			return 5







func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	get_node("PED_SPRITES").visible=true
	get_node("PED_SPRITES").set_enabled(true)
	get_node("PED_SPRITES").teleport()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	get_node("PED_SPRITES").visible=false
	get_node("PED_SPRITES").set_enabled(false)

func get_class():
	return "Enemy"


