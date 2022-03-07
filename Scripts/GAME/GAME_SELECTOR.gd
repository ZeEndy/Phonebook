extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var avalible_games=[]
var selected=0
var select_tween=0
var exe_output=[]


func _ready():
	var dirs=Directory.new()
	var find_the_fucking_exe=Directory.new()
	print(ProjectSettings.globalize_path("res://"))
	if dirs.open(ProjectSettings.globalize_path("res://")+"GAMES") == OK:
		dirs.list_dir_begin()
		while true:
			var file = dirs.get_next()
			print(file)
			if file == "":
				break
			elif not file.begins_with("."):
				if dirs.file_exists(file+"/MAIN.tscn"):
					var my_array=["","",null,false,false,null]#name,main scene,logo,hlm2 base wad,hlm2 music wad,video bg
					my_array[0]=file
					my_array[1]=file+"/MAIN.tscn"
					
					if dirs.file_exists(file+"/logo_portait.png"):
						var img=Image.new()
						img.load(ProjectSettings.globalize_path("res://")+"GAMES/"+file+"/logo_portait.png")
						var portait = ImageTexture.new()
						portait.create_from_image(img)
						my_array[2] = portait
					if dirs.file_exists(file+"/video_bg.webm"):
						my_array[5] = load(ProjectSettings.globalize_path("res://")+"GAMES/"+file+"/video_bg.webm")
					avalible_games.append(my_array)
					
					
				elif dirs.file_exists(file+"/data.win"):
					var my_array = ["","",null]
					my_array[0]=file
					find_the_fucking_exe.open(ProjectSettings.globalize_path("res://")+"GAMES/"+file)
					find_the_fucking_exe.list_dir_begin()
					while true:
						var file2=find_the_fucking_exe.get_next()
						if file2 == "":
							break
						elif file2.ends_with(".exe"):
							my_array[1] = file2
					if dirs.file_exists(file+"/logo_portait.png"):
						var img=Image.new()
						img.load(ProjectSettings.globalize_path("res://")+"GAMES/"+file+"/logo_portait.png")
						var portait = ImageTexture.new()
						portait.create_from_image(img)
						my_array[2]=portait
					avalible_games.append(my_array)
		
		dirs.list_dir_end()
	for i in avalible_games.size():
		print(i)
		if avalible_games[i][5] != null:
			var new_video = VideoPlayer.new()
			get_node("videos").add_child(new_video)
			new_video.stream = avalible_games[i][5]
			new_video.volume = 0
			new_video.play()
		if avalible_games[i][2] != null:
			var new_sprite=Sprite.new()
			get_node("logos").add_child(new_sprite)
			new_sprite.global_position = Vector2(125,125+450)
			new_sprite.global_position.x += 600*i
			new_sprite.texture = avalible_games[i][2]
			new_sprite.centered = true
#	get_tree().change_scene("res://GAMES/HLM2/MAIN.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("ColorRect").rect_size=get_viewport().size
	select_tween = lerp(select_tween,selected,25*delta)
	selected=clamp_loop(selected+(int(Input.is_action_just_pressed("right"))-int(Input.is_action_just_pressed("left"))),0,get_node("logos").get_child_count()-1)
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left"):
		AudioManager.play_audio("res://Data/DEFAULT/SOUNDS/snd_selector_hover"+String(1)+".wav")
	var aspect_ratio=get_viewport().size.x/get_viewport().size.y
	var print_arr=[]
	#do the logo positions and sizing
	for i in range(0,get_node("logos").get_child_count()):
		if get_node("logos").get_child(i) is Sprite:
			var dist_to_var=get_node("logos").get_child_count()-((Vector2(selected,0).distance_to(Vector2(i,0))))
			dist_to_var=clamp(dist_to_var,0,get_node("logos").get_child_count())/get_node("logos").get_child_count()
			get_node("logos").get_child(i).global_position=Vector2(get_viewport().size.x/2+(
				(i-select_tween)
				*
				600
			),get_viewport().size.y/2)
			if i == selected:
				get_node("logos").get_child(i).scale=lerp(get_node("logos").get_child(i).scale,Vector2(1.25,1.25),25*delta)
				get_node("logos").get_child(i).modulate=lerp(get_node("logos").get_child(i).modulate,Color(1,1,1),25*delta)
				get_node("logos").get_child(i).z_index=2
				get_node("videos").get_child(i).modulate.a=lerp(get_node("videos").get_child(i).modulate.a,1,25*delta)
				if Input.is_action_just_pressed("attack"):
					get_node("videos").get_child(i).stream_position=0
			else:
				get_node("logos").get_child(i).z_index=0
				if get_node("logos").get_child(i).scale!=Vector2(0.125,0.125):
					get_node("logos").get_child(i).z_index=1
				get_node("logos").get_child(i).scale=lerp(get_node("logos").get_child(i).scale,Vector2(1,1)*dist_to_var,10*delta)
				get_node("logos").get_child(i).scale.x=clamp(get_node("logos").get_child(i).scale.x,0.125,20)
				get_node("logos").get_child(i).scale.y=clamp(get_node("logos").get_child(i).scale.y,0.125,20)
				get_node("logos").get_child(i).modulate.a=lerp(get_node("logos").get_child(i).modulate.a,dist_to_var,10*delta)
				
				get_node("videos").get_child(i).modulate.a=lerp(get_node("videos").get_child(i).modulate.a,0,25*delta)
	#switch when selected
#	switch_video_bg(avalible_games[selected][5])
	if Input.is_action_just_pressed("ui_accept"):
		print("res://GAMES/"+avalible_games[selected][0])
		if avalible_games[selected][1].ends_with("tscn"):
			get_tree().change_scene("res://GAMES/"+avalible_games[selected][1])
		else:
			var args=PoolStringArray([""])
			var exe_pos=ProjectSettings.globalize_path("res://").replace("/","\\")+"GAMES\\"+avalible_games[selected][0]+"\\"+avalible_games[selected][1]
			var _piss=OS.execute(exe_pos,args,false,exe_output)
	
	video_bg_center()

func clamp_loop(value=0,zero=0,one=0):
	if value>one:
		return zero
	elif value<zero:
		return one
	else:
		return value


func video_bg_center():
	for i in range(0,get_node("videos").get_child_count()):
		if get_node("videos").get_child(i) is VideoPlayer:
#			if get_node("videos").get_child(i).stream_position==get_node("VideoPlayer").:
#				get_node("videos").get_child(i).play()
			get_node("videos").get_child(i).rect_position=(get_viewport().size*0.5)-(get_node("videos").get_child(i).rect_size/2)
			get_node("videos").get_child(i).rect_size=Vector2(get_viewport().size.x,get_viewport().size.x)

#func switch_video_bg(video=null,delta=1):
#	if video!=null:
#		if get_node("VideoPlayer").stream!=video:
#			get_node("VideoPlayer").modulate.a=lerp(get_node("VideoPlayer").modulate.a,0,0.25*delta)
#			if get_node("VideoPlayer").modulate.a>=0.1:
#				get_node("VideoPlayer").stream=video
#				get_node("VideoPlayer").play()
#		else:
#			get_node("VideoPlayer").modulate.a=lerp(get_node("VideoPlayer").modulate.a,1,0.25*delta)
#	else:
#		get_node("VideoPlayer").modulate.a=lerp(get_node("VideoPlayer").modulate.a,0,0.25*delta)
#		if get_node("VideoPlayer").modulate.a==0:
#			get_node("VideoPlayer").stream=null


