extends SubViewport


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
class_name goresurf

var enabled=true
var surface_loaded=false
@export var im_enabled=false
@export var avalible_sprites: Array
@export var surface_data=[]



# Called when the node enters the scene tree for the first time.

func _ready():
	render_target_clear_mode=SubViewport.CLEAR_MODE_ONCE
	load_surface()




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_to_surface(obj_path,position=Vector2(0,0),rotation=0):
	var saved_node
	if obj_path is NodePath:
		saved_node=get_node(obj_path)
		saved_node.get_parent().remove_child(saved_node)
	else:
		if is_instance_valid(obj_path.get_parent()):
			obj_path.get_parent().remove_child(obj_path)
		saved_node=obj_path
	add_child(saved_node)
	saved_node.global_position=(((position-get_parent().get_parent().global_position).rotated(-get_parent().get_parent().global_rotation))*4.0)
	
	print(position*4.0)
	print(saved_node.global_position)
	
	saved_node.global_rotation=rotation-get_parent().get_parent().global_rotation
	saved_node.scale*=4
#	print(saved_node.global_position)
	if saved_node is AnimatedSprite2D:
		var frames_location = -1
		if avalible_sprites.size() > 1:
			for i in range(1,avalible_sprites.size()-1):
				if avalible_sprites[i] is SpriteFrames:
					if (avalible_sprites[i].get_animation_names() == saved_node.frames.get_animation_names()):
						frames_location = i
		if frames_location == -1:
			avalible_sprites.append(saved_node.frames)
			frames_location = avalible_sprites.size()-1
		var my_properties = {
			"type" : "AnimatedSprite",
			"frames" : frames_location,
			"frame" : saved_node.frame,
			"anim" : saved_node.animation,
			"off" : saved_node.offset,
			"pos" : saved_node.global_position,
			"rot" : saved_node.global_rotation,
			"sc" : saved_node.scale,
			"z" : saved_node.z_index
		}
		surface_data.append(my_properties)
	if saved_node is Sprite2D:
		var texture_location = -1
		if avalible_sprites.size() > 1:
			for i in range(1,avalible_sprites.size()-1):
				if avalible_sprites[i] is Texture2D:
					if (avalible_sprites[i] == saved_node.texture):
						texture_location = i
		if texture_location == -1:
			avalible_sprites.append(saved_node.texture)
			texture_location = avalible_sprites.size()-1
		var my_properties = {
			"type" : "Sprite",
			"texture" : texture_location,
			"off" : saved_node.offset,
			"pos" : saved_node.global_position,
			"rot" : saved_node.global_rotation,
			"sc" : saved_node.scale,
			"z" : saved_node.z_index,
			"region_rect": saved_node.region_rect,
			"region_enabled": saved_node.region_enabled
		}
		surface_data.append(my_properties)
	if saved_node is Node2D:
		for child in saved_node.get_children():
			if child is AnimatedSprite2D:
				var frames_location = -1
				if avalible_sprites.size() > 1:
					for i in range(1,avalible_sprites.size()-1):
						if avalible_sprites[i] is SpriteFrames:
							if (avalible_sprites[i].get_animation_names() == child.frames.get_animation_names()):
								frames_location = i
				if frames_location == -1:
					avalible_sprites.append(child.frames)
					frames_location = avalible_sprites.size()-1
				var my_properties = {
					"type" : "AnimatedSprite",
					"frames" : frames_location,
					"frame" : child.frame,
					"anim" : child.animation,
					"off" : child.offset,
					"pos" : child.global_position,
					"rot" : child.global_rotation,
					"sc" : child.scale,
					"z" : child.z_index
				}
				surface_data.append(my_properties)
	await  RenderingServer.frame_post_draw
	saved_node.queue_free()



func save_surface():
	pass
#	if get_texture().get_data().is_invisible()==false:
#		var img=get_texture().get_data()
#		img.lock()
#		img.flip_y()
#		var tex=ImageTexture.new()
#		tex.create_from_image(img)
#		img.unlock()
#		texture_data=tex
#	if im_enabled==true:
#		img.save_png("res://Untitled.png")



func load_surface():
	if avalible_sprites.size()>1:
		if surface_loaded==false:
			for i in surface_data:
				if i!=null:
					if i.type=="AnimatedSprite":
						var del_sprite=AnimatedSprite2D.new()
						del_sprite.frames=avalible_sprites[i.frames]
						del_sprite.speed_scale=0
						del_sprite.animation=i.anim
						del_sprite.offset=i.off
						add_child(del_sprite)
						del_sprite.frame=i.frame
						del_sprite.global_position=i.pos
						del_sprite.global_rotation=i.rot
						del_sprite.scale=i.sc
						del_sprite.z_index=i.z
					if i.type=="Sprite":
						var del_sprite=Sprite2D.new()
						del_sprite.texture=avalible_sprites[i.texture]
						del_sprite.offset=i.off
						add_child(del_sprite)
						del_sprite.global_position=i.pos
						del_sprite.global_rotation=i.rot
						del_sprite.scale=i.sc
						del_sprite.z_index=i.z
						del_sprite.region_rect=i.region_rect
						del_sprite.region_enabled=i.region_enabled
			await RenderingServer.frame_post_draw
			await RenderingServer.frame_post_draw
			for i in get_children():
				i.queue_free()
			surface_loaded=true
	else:
		surface_loaded=true
#	if surface_loaded==false:
#		var sprite=Sprite.new()
#		sprite.centered=false
#		sprite.texture=texture_data
#		add_child(sprite)
#		yield(VisualServer, "frame_post_draw")
#		sprite.queue_free()
#		surface_loaded=true
