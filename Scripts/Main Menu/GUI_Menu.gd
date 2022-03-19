extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#TODO ADD THE FUCKING FONT MANAGMENT
#testing out the github webhook

export var start_room=""

var title_options=[
	["Start",3],
	["Continue",3],
	["Editor",3],
	["Options",3],
	["Quit Game",3]
	]

var options_options=[
	["Content",true],
	["Controls",""],
	["Graphics","Graphics"],
	["Audio",],
	["Language",3],
	["Achievements",3]
	]

var title_dir=0


enum menu_states{
	TITLE,
	CHAPTERS,
	OPTIONS,
	EDITOR
}


var current_menu=menu_states.TITLE
var doing_action=false
var current_selection=title_options[0]


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_nodes_in_group("GLOBAL")[0].play_song()
#	var temp_font = load("res://Justice.png")
#	for i in title_options:
#		get_node("Title screen/Text/"+i[0]).theme.default_font.add_texture(temp_font)
#	get_node("Title screen/Text/Title").theme.default_font.add_texture(temp_font)
#	var title=DynamicFont.new()
#	title.font_data=_wad.get(_wad.lazy_find("fntTitle.fnt"))
#
#	get_node("Title").set("custom_fonts/normal_font",title)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if current_menu==menu_states.TITLE:
		title_draw(delta)
		title_functions()
	elif current_menu==menu_states.OPTIONS:
		if doing_action==false:
			if Input.is_action_just_pressed("ui_cancel"):
				doing_action=true
		else:
			get_tree().get_nodes_in_group("GLOBAL")[0].fade=true
			if get_tree().get_nodes_in_group("GLOBAL")[0].fade_color==1:
				get_tree().get_nodes_in_group("GLOBAL")[0].fade=false
				current_menu=menu_states.TITLE
				doing_action=false
				toggle_section()

func _physics_process(_delta):
	if current_menu==menu_states.TITLE:
		var shader1=get_node("Title screen/Color layer 1/ColorRect").material
		var shader2=get_node("Title screen/Color layer 2/ColorRect").material
		shader1.set_shader_param("radius",lerp(shader1.get_shader_param("radius"),rand_range(0,0.3),0.10))
		
		shader2.set_shader_param("radius",lerp(shader2.get_shader_param("radius"),rand_range(0.2,0.5),0.10))


func title_functions():
	if doing_action==false:
		if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("down"):
			if title_options.find(current_selection)!=title_options.size()-1:
				current_selection=title_options[title_options.find(current_selection)+1]
			else:
				current_selection=title_options[0]
			print(current_selection)
		if Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("up"):
			if title_options.find(current_selection)!=0:
				current_selection=title_options[title_options.find(current_selection)-1]
			else:
				current_selection=title_options[title_options.size()-1]
			print(current_selection)
		
		if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("execute"):
			if current_selection==title_options[0]:
				get_tree().get_root().get_node("GAME").switch_scene(start_room,true,false)
				
			elif current_selection==title_options[1]:
				#code for continue
				pass
			elif current_selection==title_options[2]:
				get_tree().get_root().get_node("GAME").switch_scene("res://Data/DEFAULT/ROOMS/ROOM_EDITOR.tscn",true,false)
				
			elif current_selection==title_options[3]:
				doing_action=true
				pass
			elif current_selection==title_options[4]:
				doing_action=true
	else:
		if current_selection==title_options[3]:
			get_tree().get_nodes_in_group("GLOBAL")[0].fade=true
			if get_tree().get_nodes_in_group("GLOBAL")[0].fade_color==1:
				get_tree().get_nodes_in_group("GLOBAL")[0].fade=false
				current_menu=menu_states.OPTIONS
				doing_action=false
				toggle_section()
		elif current_selection==title_options[4]:
			get_tree().get_nodes_in_group("GLOBAL")[0].fade=true
			if get_tree().get_nodes_in_group("GLOBAL")[0].fade_color==1:
				var shutup=get_tree().change_scene("res://Game_Selector.tscn")

func title_draw(delta):
	if doing_action==false:
#		get_node("Title screen/Text").scale=get_viewport().size/(get_viewport().size*get_node("Camera2D").zoom)
		
		title_dir+=30*delta
		var title_rotation=(Vector2(0.05,0).rotated(deg2rad(title_dir))).x
		get_node("Title screen/Text/Title").rect_rotation=title_rotation
		for i in title_options:
			if current_selection!=i:
				
				get_node("Title screen/Text/"+i[0]).modulate=Color(0,0,0)
				if i[1]>3:
					i[1]-=0.5*60*delta
				else: 
					i[1]=3
				for x in floor(i[1]):
					var text="/"+i[0]
					get_node("Title screen/Text/"+i[0]+text.repeat(x+1)).rect_position.x=0
			else:
				get_node("Title screen/Text/"+i[0]).modulate=Color(1,1,1)
				if i[1]<7:
					i[1]+=0.5*60*delta
				else:
					i[1]=7
				for x in floor(i[1]):
					var text="/"+i[0]
					if get_node_or_null("Title screen/Text/"+i[0]+text.repeat(x+1))!=null:
						get_node("Title screen/Text/"+i[0]+text.repeat(x+1)).rect_position.x= -1
				
				
			
#			get_node("Title screen/Text/"+i[0]).rect_rotation=rad2deg(title_rotation)
#			get_node("Title screen/Text/"+i[0]).rect_pivot_offset=get_node("Title screen/Text/"+i[0]).rect_size/2
#
#
#
#		get_node("Title screen/Text/Title").rect_rotation=rad2deg(title_rotation)
#		get_node("Title screen/Text/Title").rect_pivot_offset=get_node("Title screen/Text/Title").rect_size/2
		
		
		
	get_node("Title screen/Inverse/ColorRect").rect_size=get_viewport_rect().size
	get_node("Title screen/Background/Background").rect_size=get_viewport_rect().size
	if get_viewport_rect().size.x>get_viewport_rect().size.y:
		get_node("Title screen/Color layer 1/ColorRect").rect_size=Vector2(get_viewport_rect().size.x,get_viewport_rect().size.x)
		get_node("Title screen/Color layer 2/ColorRect").rect_size=Vector2(get_viewport_rect().size.x,get_viewport_rect().size.x)
		
		var posy=(get_viewport_rect().size.x/2*get_node("Camera2D").zoom.x)-get_node("Title screen/Color layer 1/ColorRect").rect_size.y/2
		
		get_node("Title screen/Color layer 1/ColorRect").rect_position.y=posy
		get_node("Title screen/Color layer 2/ColorRect").rect_position.y=posy
	else:
		get_node("Title screen/Color layer 1/ColorRect").rect_size=Vector2(get_viewport_rect().size.y,get_viewport_rect().size.y)
		get_node("Title screen/Color layer 2/ColorRect").rect_size=Vector2(get_viewport_rect().size.y,get_viewport_rect().size.y)
		
		var posy=(get_viewport_rect().size.y/2*get_node("Camera2D").zoom.y)-get_node("Title screen/Color layer 1/ColorRect").rect_size.x/2
		
		get_node("Title screen/Color layer 1/ColorRect").rect_position.y=posy
		get_node("Title screen/Color layer 2/ColorRect").rect_position.y=posy
	


func toggle_section():
	for i in get_children():
		if (i is Node2D) && !(i is Camera2D):
			if i!=get_current_section_node():
				i.visible=false
				section_visible(i,false)
			else:
				i.visible=true
				section_visible(i,true)

func section_visible(node,vis):
	for c in node.get_children():
		if "visible" in c:
			c.visible=vis
		section_visible(c,vis)


func get_current_section_node():
	if current_menu==menu_states.TITLE:
		return get_node("Title screen")
	elif current_menu==menu_states.OPTIONS:
		return get_node("Options")
	elif current_menu==menu_states.EDITOR:
		return get_node("Editor")
	elif current_menu==menu_states.CHAPTERS:
		return get_node("Chapters")
	pass



