extends Node2D


@onready var anim_player=get_node("AnimationPlayer")
@onready var area2d=get_node("Area2d")


@onready var point=get_node("Point")
@onready var line=get_node("Line2d")
@onready var text=get_node("Text")

signal interacted(obj)

var player_pos=Vector2()
var line_pos=Vector2(0,0)
var lenght=0.0
var force_disappear=false

# Called when the node enters the scene tree for the first time.
func _ready():
	line.global_position=Vector2(0,0)
#	line_pos=global_position



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	text.global_rotation=0
	line.global_rotation=0
	if Input.is_action_just_pressed("inter"):
		if area2d.get_overlapping_bodies().size()>0:
			var wall_query=PhysicsRayQueryParameters2D.create(global_position,area2d.get_overlapping_bodies()[0].global_position,32)
			var wall_check = get_world_2d().direct_space_state.intersect_ray(wall_query)
			if wall_check=={}:
				emit_my_signal()
				anim_disapear()
				force_disappear=true
			else:
				force_disappear=false
	if area2d.get_overlapping_bodies().size()>0 && force_disappear==false && get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,area2d.get_overlapping_bodies()[0].global_position,32))=={}:
			anim_appear()
			point.modulate.a=lerp(point.modulate.a,1.0,clamp(10*delta,0,1))
			player_pos=area2d.get_overlapping_bodies()[0].global_position
			var angle_of_interact=global_position.angle_to_point(player_pos)-PI
			lenght=lerp(lenght,7.25,clamp(10*delta,0,1))
			line_pos=text.global_position+Vector2(0.0,lenght)
			line.points=PackedVector2Array([global_position,line_pos])
			line.modulate.a=lerp(line.modulate.a,1.0,clamp(10*delta,0,1))
			text.global_position=lerp(text.global_position,global_position+Vector2(24.0,0).rotated(angle_of_interact),clamp(24*delta,0,1))
	else:
		line_pos=lerp(line_pos,global_position,clamp(10*delta,0,1))
		point.modulate.a=lerp(point.modulate.a,0.0,clamp(10*delta,0,1))
		line.points=PackedVector2Array([global_position,line_pos])
		line.modulate.a=lerp(line.modulate.a,0.0,10*delta)
		anim_disapear()



func return_to_showup():
	if anim_player.current_animation=="":
		anim_player.play("ShowUp")
	else:
		var saved_time=anim_player.current_animation_length-anim_player.current_animation_position
		anim_player.play("ShowUp")
		anim_player.seek(saved_time,true)



func anim_appear():
	if anim_player.assigned_animation!="ShowUp":

		if anim_player.current_animation=="":
			anim_player.play("ShowUp")
		else:
			var saved_time=anim_player.current_animation_length-anim_player.current_animation_position
			anim_player.play("ShowUp")
			anim_player.seek(saved_time,true)



func anim_disapear():
	if anim_player.assigned_animation!="FuckOff":
		if anim_player.current_animation=="":
			anim_player.play("FuckOff")
		else:
			var saved_time=anim_player.current_animation_length-anim_player.current_animation_position
			anim_player.play("FuckOff")
			anim_player.seek(saved_time,true)


func emit_my_signal():
	interacted.emit(self)

func _on_interactable_interacted(obj):
	print(obj)


func _on_area_2d_body_entered(body):
	print(body)
