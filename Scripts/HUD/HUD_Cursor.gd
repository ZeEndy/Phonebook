extends AnimatedSprite
# normal means unarmed
var cursor_anim="default"
var mouse = Vector2()
#checking if the player is holding f
var slow_mo=false
var factor=0.8
var p_pos=Vector2()
var player
var cursor_scale=1

var real_mouse=Vector2()

var focus_input="mouse"

var _wad=null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if get_tree().get_root().get_node("GAME").cursor_position!=null:
		real_mouse=get_tree().get_root().get_node("GAME").cursor_position
#	OS.window_maximized=true

func _process(_delta):
	#normal hm code for cursor movement
	if get_tree().get_nodes_in_group("Player")!=[]:
		p_pos=get_tree().get_nodes_in_group("Player")[0].get_parent().sprites.global_position
#		global_rotation=get_tree().get_nodes_in_group("Player")[0].get_parent().body_direction
		get_tree().get_nodes_in_group("Player")[0].get_parent().cursor_pos=mouse
		if Input.is_action_just_pressed("spawn_a10"):
			var spawn_a10=load("res://Data/EXPERIMENTS/A10/A10.tscn").instance()
			spawn_a10.global_position=global_position
			spawn_a10.global_rotation=get_tree().get_nodes_in_group("Player")[0].get_parent().body_direction
			get_parent().add_child(spawn_a10)
	
	
	
#	var camera = get_tree().get_nodes_in_group("Camera")[0]
	
#	scale.x=(1+camera.shake*2)*cursor_scale
#	scale.y=(1+camera.shake*2)*cursor_scale
	
	
	var width=get_viewport_rect().size.x
	var height=get_viewport_rect().size.y
	
	if Input.is_action_just_pressed("DEBUG_SPAWN_ENEMY"):
		var fart = load("res://Data/DEFAULT/ENTS/PED_ENEMY.tscn").instance()
		get_parent().add_child(fart)
		fart.global_position=global_position
		

	if Vector2(Input.get_action_strength("look_left")-Input.get_action_strength("look_right"),Input.get_action_strength("look_up")-Input.get_action_strength("look_down")).length()>0:
		focus_input="controller"
	
	if focus_input=="controller":
		if Vector2(Input.get_action_strength("look_left")-Input.get_action_strength("look_right"),Input.get_action_strength("look_up")-Input.get_action_strength("look_down")).length()>0:
			if !Input.is_action_pressed("far_look"):
				mouse=Vector2(Input.get_action_strength("look_right")-Input.get_action_strength("look_left"),Input.get_action_strength("look_down")-Input.get_action_strength("look_up")).normalized()*54
			else:
				mouse=Vector2(Input.get_action_strength("look_right")-Input.get_action_strength("look_left"),Input.get_action_strength("look_down")-Input.get_action_strength("look_up"))*270
	else:
		mouse.x=((real_mouse.x-width*0.5)*(width*0.26/width))*factor
		mouse.y=((real_mouse.y-height*0.5)*(height*0.26/height))*factor
		
		real_mouse.x=clamp(real_mouse.x,0,width)
		real_mouse.y=clamp(real_mouse.y,0,height)
	position = lerp(position,p_pos+mouse,0.999)
	
	
	if Input.is_action_pressed("far_look"):
		factor=lerp(factor,1.6,0.5)
	else:
		factor=lerp(factor,0.9,0.5)
	

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		real_mouse+=event.relative
		focus_input="mouse"
