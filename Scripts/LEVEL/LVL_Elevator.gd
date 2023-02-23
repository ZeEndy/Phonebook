extends Sprite2D


@onready var cunt=get_node("Button/CanvasLayer/Container/Control/ColorRect/GridContainer")
@onready var fade_me_up_scotty=get_node("Button/CanvasLayer/Fade_me_up_scotty")
@onready var node2d=get_node("Node2d")

@export var targets=[]
var selected_floor=-1

@export var elevator_time=0.0
var timer=0.0
var player_in_elevator=false

func _ready():
	
	var cunt_count=cunt.get_child_count()
	for i in cunt.get_child_count():
		if i>targets.size()-1:
			cunt_count-=1
			cunt.get_child(i).visible=false
	for i in targets.size():
		var id=targets[i]
		if get_viewport()==get_node(id[0]):
			selected_floor=i
		id[0]=get_node(id[0])
	get_node("Button/CanvasLayer/Container/Control/ColorRect").size.y=100.0*(ceil(float(cunt_count)*0.5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	node2d.global_position=-get_viewport_transform().origin/get_viewport_transform().get_scale()
	get_node("Button/CanvasLayer/Container").position=get_node("Button/Text").get_screen_transform().origin+Vector2(-198,-14)
	get_node("Node2d/ColorRect").size=get_viewport_rect().size
	node2d.z_index=z_index-6
	for i in cunt.get_child_count():
		if i == selected_floor:
			cunt.get_child(i).modulate=Color(0.7,0.7,0.7,1.0)
		else:
			cunt.get_child(i).modulate=Color(1.0,1.0,1.0,1.0)
	if timer>0:
		timer-=delta
		if z_index!=8:
			for i in get_node("Area2d").get_overlapping_bodies():
				var parent_obj=i.get_parent()
				if parent_obj is PED:
					player_in_elevator=true
					parent_obj.z_index+=6
				else:
					z_index+=6
			z_index=8
		
		
		
		if timer<elevator_time*0.10:
			if get_parent() != targets[selected_floor][0]:
				var floor=targets[selected_floor][0]
				for i in get_node("Area2d").get_overlapping_bodies():
					var parent_obj=i.get_parent()
					if parent_obj is PED:
						var saved_node=parent_obj
						get_viewport().remove_child(saved_node)
						floor.add_child(saved_node)
					else:
						var saved_node=i
						get_viewport().remove_child(saved_node)
						floor.add_child(saved_node)
				get_parent().remove_child(self)
				floor.add_child(self)
			if player_in_elevator==true:
				node2d.modulate.a=lerp(node2d.modulate.a,0.0,5*delta)
		else:
			if player_in_elevator==true:
				node2d.modulate.a=lerp(node2d.modulate.a,1.0,5*delta)
			
		if timer<=0:
			get_node(targets[selected_floor][1]).emit_my_signal()
			if z_index!=2:
				for i in get_node("Area2d").get_overlapping_bodies():
					if i.get_parent() is PED:
						player_in_elevator=true
						i.get_parent().z_index-=6
					else:
						z_index-=6
				z_index=2
	else:
		if player_in_elevator==true:
			node2d.modulate.a=lerp(node2d.modulate.a,0.0,5*delta)
			if node2d.modulate.a==0.0:
				player_in_elevator=false
	if fade_me_up_scotty.assigned_animation=="In" && Input.is_action_just_pressed("cancel"):
		hide_buttons()
	


func _on_door_interacted(obj):
	var obj_anim_player=obj.get_node("Animation")
	if obj_anim_player.assigned_animation!="Open":
		if obj_anim_player.current_animation=="":
			obj_anim_player.play("Open")
		else:
			var saved_time=obj_anim_player.current_animation_length-obj_anim_player.current_animation_position
			obj_anim_player.play("Open")
			obj_anim_player.seek(saved_time,true)
	
	elif obj_anim_player.assigned_animation!="Close":
		
		if obj_anim_player.current_animation=="":
			obj_anim_player.play("Close")
		else:
			var saved_time=obj_anim_player.current_animation_length-obj_anim_player.current_animation_position
			obj_anim_player.play("Close")
			obj_anim_player.seek(saved_time,true)
	


func _on_button_interacted(obj):
	show_buttons()
	obj.anim_disapear()


func show_buttons():
	if fade_me_up_scotty.assigned_animation!="In":
		if fade_me_up_scotty.current_animation=="":
			fade_me_up_scotty.play("In")
		else:
			var saved_time=fade_me_up_scotty.current_animation_length-fade_me_up_scotty.current_animation_position
			fade_me_up_scotty.play("in")
			fade_me_up_scotty.seek(saved_time,true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func select_floor(floor):
	if selected_floor!=floor:
		selected_floor=floor
		for i in get_children():
			if "Door" in i.name:
				if i.get_node("Animation").assigned_animation=="Open":
					_on_door_interacted(i)
		hide_buttons()
		
		timer=elevator_time

func hide_buttons():
	if fade_me_up_scotty.assigned_animation!="Out":
		if fade_me_up_scotty.current_animation=="":
			fade_me_up_scotty.play("Out")
		else:
			var saved_time=fade_me_up_scotty.current_animation_length-fade_me_up_scotty.current_animation_position
			fade_me_up_scotty.play("Out")
			fade_me_up_scotty.seek(saved_time,true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
