extends PED

#class_name Enemy


enum Enemy_t {
	RANDOM,
	PATROL,
	DOG_PATROL,
	STATIONARY
	FAT
}

onready var Legs = get_node("PED_SPRITES/Legs")
onready var Body = get_node("PED_SPRITES/Body")
onready var KBody = get_node("PED_COL")

export var CHECKRELOAD = 30
export var ALERTWAIT = 16
export var TURNSPEED = 10
export var WALKSPEED = 1
export var PATHSPEED = 2
export var RUNSPEED = 3
export var RUNSPEED_DOG = 5
export var VIEW_DIST = 280


var speed = 0
var direction = 0

export(Enemy_t) var behaviour = Enemy_t.PATROL



var players = []
var player_focused = null

var checkReload = 0
var alertWait = 0
var script_state = 0
var random_timer = 0

var delta_time = 0
var _body_index = 0
var _leg_index = 0
var path = []

func _ready():
	prints([sprites.get_node("Body").animation,sprite_index])
# oh boy this isn't going to be fun
#	Body = get_node(Body)
#	Legs = get_node(Legs)
#	KBody = get_node(KBody)
#
#
#	Body.frames = _wad.meta_sprite("Atlases/Enemy_Mafia.meta")
#	#	var weapon_name = GameManager.Weapon.keys()[weapon]
#	Body.play("sprEMafiaWalk" + weapon_name.capitalize().replace(' ',''))
#	Body.speed_scale = 0
#
#	Legs.frames = Body.frames
#	Legs.play("sprEMafiaLegs")
#	Legs.speed_scale = 0
	players = get_tree().get_nodes_in_group("Player")


func _physics_process(delta):
	if state==ped_states.alive:
		player_focused=get_tree().get_nodes_in_group("Player")[0]
		delta_time = delta * 60
		if   script_state == 0: state0()
		elif script_state == 1: state1()
		elif script_state == 2: state2()
		elif script_state == 3: state3()
		else: return
		var v = speed * Vector2(cos(deg_to_radrad(direction))deg_to_radeg_to_rad(direction)))# * delta_time
		#KBody.position += v
		KBody.linear_velocity=v*60
		Body.rotation_degrees = direction
		Legs.rotation_degrees = direction
		_body_index += speed * 0.15
	#	Body.frame = int(_body_index) % Body.frames.get_frame_count(Body.animation)
		_leg_index += speed * 0.15
	#	Legs.frame = int(_leg_index) % Legs.frames.get_frame_count(Legs.animation)
	#	$KBody/Label.text = str(script_state)
	#	$KBody/Label2.text = str(checkReload)
	#	$KBody/Label3.text = str(alertWait)

	#func _draw():
		#for c in get_children():
		#	if c is AnimatedSprite:
	#	var c = Legs
	#	var sprite_tex = c.frames.get_frame(c.animation, c.frame)
		#draw_set_transform(c.global_position - position, c.rotation, Vector2.ONE)
		#draw_texture(sprite_tex, Vector2(1,1).rotated(-c.rotation) - sprite_tex.get_size()/2 + c.offset, Color(0,0,0,0.5))
	#	c = Body
	#	sprite_tex = c.frames.get_frame(c.animation, c.frame)
	#	draw_set_transform(c.global_position - position, c.rotation, Vector2.ONE)
	#	draw_texture(sprite_tex, Vector2(1,1).rotated(-c.rotation) - sprite_tex.get_size()/2 + c.offset, Color(0,0,0,0.5))

	#this function is not useful
	#throwing all the sprite properties to default parent script
	#func init_enemy(spr_name):
	#	#weapon = _weapon
	#
	##usless
	##	# get weapon 
	##	for w in GameManager.Weapon.keys():
	##		if w.capitalize().replace(' ','') in spr_name:
	##			weapon = GameManager.Weapon[w]
	##			break
	#
	#	var d = {
	#	#	Faction		Normal legs		Fat legs
	#		"Mafia":	["sprEMafia",	"sprEMafiaFat"],
	#		"Gang":		["sprEGang",	"sprEGangFat"],
	#		"Police":	["sprPolice",	"sprFatPolice"],
	#		"Soldier":	["sprSoldier",	"sprFatSoldier"],
	#		"Prisoner":	["sprPrisoner",	"sprPrisonerFat"],
	#		"Colombian":["sprColombian","sprEMafiaFat"],
	#		"Guard":	["sprGuard"],
	#		"Dog":		[],
	##		"PigButcher":["sprVictim"],
	#	}
	#
	#
	#	var fat = "Fat" in spr_name
	#	var dog = "Dog" in spr_name
	#
	#	var faction_name = "Mafia"
	#	var legs_name = "sprEMafia"
	#	for i in ["Gang", "Police", "Soldier", "Prisoner", "Colombian", "Guard", "Dog"]:
	#		if i in spr_name:
	#			faction_name = i
	#			if !dog:
	#				legs_name = d[i][0]
	#				if fat:
	#					legs_name = d[i][1]
	#			break
	#	# edge cases
	#	if faction_name == "Colombian" and fat:
	#		faction_name = "Mafia"
	#	Body.frames = _wad.meta_sprite("Atlases/Enemy_" + faction_name + ".meta")
	#	Body.play(spr_name)
	#	Body.speed_scale = 0
	#
	#	if !dog:
	#		Legs.frames = Body.frames
	#		Legs.play(legs_name + "Legs")
	#		Legs.speed_scale = 0
	#	else:
	#		Legs.hide()
	#	players = get_tree().get_nodes_in_group("Player")

	#func weapon_to_anim(_weapon):
	#	if weapon_type(_weapon) == GameManager.Weapon.FAT:
	#		return faction + "FatWalk"
	#	var weapon_name = GameManager.Weapon.keys()[weapon]
	#	return faction + "Walk" + weapon_name.capitalize().replace(' ','')
	#func anim_to_weapon(sprite_name):
	#	sprite_name = sprite_name.replace("Walk", '')
	#	sprite_name = sprite_name.replace("Attack", '')
	#	var ret = sprite_name.substr(len(faction), 999).to_upper()
	#	return GameManager.Weapon[ret]
	#func anim_to_faction(sprite_name):
	#	for i in ["FatWalk", "Walk", "Attack"]:
	#		if i in sprite_name:
	#			return sprite_name.substr(0, sprite_name.find(i))
	#	assert(true == false)

func die():
	switch_state(-1)

func weapon_type(weapon):
	return gun.type

func switch_state(new_state):
	if state==ped_states.alive:
		if new_state == -1 and script_state != -1:

			#usles considering were using a default ped

	#		if weapon_type(weapon) != GameManager.Weapon_t.FAT\
	#		and weapon_type(weapon) != GameManager.Weapon_t.DOG:
	#			var w = GameManager.weapon_prefab.instantiate()
	#			var lvl = get_tree().get_nodes_in_group("Level")[0]
	#			lvl.add_child(w)
	#			w.global_position = KBody.global_position
	#			w.speed = 2 + randf() * 2
	#			w.direction = randf() * 360
	#			w.weapon_id = weapon
	#			var l = GameManager.player_wad.single_frame("Atlases/Weapons.meta", "spr" + GameManager.get_weapon_name(weapon))
	#			w.sprite.texture = l[0]
	#			w.sprite.offset = l[1]
	#			w.get_node("Smoothing2D").teleport()


			# Turn into a bullet spunge
			var bullets = get_tree().get_nodes_in_group("Bullet")
			var kill_dir = 0
			var kill_spd = 2 + randf() * 1
			for b in bullets:
				if b.KBody.global_position.distance_squared_to(KBody.global_position) < 60*60:
					kill_dir = b.rotation
					kill_spd += 0.25
					b.queue_free()
			# Jill yorself
	#		var dead = GameManager.object_prefab.instantiate()
	#		get_parent().add_child(dead)
	#		dead.global_position = KBody.global_position
	#		dead.sprite.get_parent().teleport()
	#		dead.direction = kill_dir
	#		dead.sprite.rotation = kill_dir
	#		dead.speed = kill_spd
	#		dead.friction = 0.25
	#		dead.z_index = -1
	#		for a in Body.frames.get_animation_names():
	#			if "Dead" in a:
	#				dead.sprite.texture = Body.frames.get_frame(a, randi() % Body.frames.get_frame_count(a))
	#				break
			#AnimatedSprite.new().frames.get_frame(Body.animation, Body.frame)
			#var l = GameManager.player_wad.single_frame("")
			queue_free()
	# yeah :/
		if new_state == 3:
			var navmap = get_tree().get_nodes_in_group("NavMap")[0]
			path = navmap.get_new_path(KBody.global_position, player_focused.position)
			if not path or len(path) < 2:
				switch_state(0)
				return
			_target_point_world = path[1]
		script_state = new_state

func state0():
	# neutral behaviors
	if behaviour == Enemy_t.RANDOM:
			random_timer -= 1 * delta_time
			if (random_timer <= 0) or speed > 2:
				direction = randi() % 360
				speed = randi() % 2
				random_timer = 60 + (randi() % 61)
			var v = Vector2(speed * cos(deg_to_radrad(direction)) * delta_time, speed deg_to_radeg_to_rad(direction)) * delta_time)
			
			var bounce_obj=Physics2DTestMotionResult.new()
			#this causes a masive memory leak. too bad
			#TODO: find a better way to bounce
			var c = KBody.test_motion(v,true,0.08,bounce_obj)
			if c:
				v = v.bounce(bounce_obj.collision_normal)
				direction = rad2deg(v.angle())
	elif behaviour == Enemy_t.PATROL:
			speed = WALKSPEED
			#direction = round(direction/10)*10
			var v = 8 * Vector2(cos(deg_to_radrad(direction)) * delta_timedeg_to_radeg_to_rad(direction)) * delta_time)
			var c = KBody.test_motion(v)
			if c:
				direction -= 10 * delta_time
			else:
				var dif = fmod(direction, 90)
				if abs(dif) > 10 * delta_time:
					direction -= 10 * delta_time
				else:
					direction -= dif
			#if !place_free(x+lengthdir_x(8,direction),y+lengthdir_y(direction))
			# TODO: turn on collisions and stuff
	elif behaviour == Enemy_t.DOG_PATROL:
			speed = WALKSPEED * delta_time
			# TODO: turn on corners and stuff
	elif behaviour == Enemy_t.STATIONARY:
			speed = 0
	
	# main los check timer
	if(checkReload <= 0):
		# 0 no los, 1 direct, or 2 indirect
		var los = check_los()
		if (los == 1): alertWait = ALERTWAIT
		if (los == 2): switch_state(2)
		checkReload = CHECKRELOAD

	# reaction delay timer
	if (alertWait <= 0 and alertWait != -1):
		var los = check_los()
		if (los == 1): switch_state(1)
		if (los == 2): switch_state(2)
		alertWait = -1

	# decrement timers
	if (checkReload > 0 && alertWait == -1): checkReload -= 1 * delta_time
	if (alertWait > -1): alertWait -= 1 * delta_time

func state1():
	if player_focused == null:
		switch_state(0)
	# TODO: add blunt (unarmed) edge case
	var d = 12*12
	var r = RUNSPEED
	match gun.type:
		"semi",\
		"auto",\
		"burst":
			d = 80*80
			continue
		"dog":
			r = RUNSPEED_DOG
			continue
		"semi",\
		"auto",\
		"burst",\
		"melee",\
		"dog":
			if KBody.global_position.distance_squared_to(player_focused.position) > d:
				speed = min(speed + 0.5 * delta_time, r)
			else:
				speed = max(speed - 0.25 * delta_time, 0)
			direction = hm1_rotate(direction, rad2deg(player_focused.position.angle_to_point(KBody.global_position)), TURNSPEED * delta_time)
	var los = check_los() # 0 none, 1 direct, 2 indirect
	#if (los == 1): switch_state(1)
	if (los == 0): switch_state(3)

func state2():
	if player_focused == null:
		switch_state(0)
	if gun.type=="semi" or gun.type=="auto" or gun.type=="burst":
		var dist_to_focused_player = VIEW_DIST + 1; # implement later idk
		if (dist_to_focused_player > VIEW_DIST):
			switch_state(3)
			return
		# TODO: die immediately 
		enemy_shoot()
		check_los()
	
	switch_state(3)

var _target_point_world = Vector2.ZERO


func state3():
	# pathing nonsense
	#var _target_point_world = path[path_index]
	speed = 0
	#var desired_velocity = (_target_point_world - KBody.global_position).normalized() * 5 * 60# * speed
	#var steering = desired_velocity - _velocity
	#_velocity += steering
	#KBody.position += _velocity * get_process_delta_time()
	direction = rad2deg((_target_point_world - KBody.global_position).angle())
	speed = PATHSPEED
	var _arrived_to_next_point = KBody.global_position.distance_to(_target_point_world) < 6
	if _arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
			switch_state(0)
			return
		_target_point_world = path[0]
	
	var los = check_los() # 0 none, 1 direct, 2 indirect
	if (los == 1): switch_state(1)
	#if (los == 2): switch_state(2)


func check_los():
	# 0 none, 1 direct, 2 indirect
	var space_state = get_world_2d().direct_space_state
	var los = 0
	var _players = players
	if player_focused != null:
		_players = [player_focused]
	for p in _players:
		if p == null: continue
		var dist = KBody.global_position.distance_squared_to(p.position)
		var angl = rad2deg(KBody.global_position.angle_to_point(p.position))
		var vd = Vector2(cos(deg_to_rad(angl+90)), sin(deg_to_rad(angl+90))) * 4
		var result1 = space_state.intersect_ray(KBody.global_position + vd, p.position + vd, [KBody], 0b00000000000000000101)
		vd = Vector2(cos(deg_to_rad(angl-90)), sin(deg_to_rad(angl-90))) * 4
		var result2 = space_state.intersect_ray(KBody.global_position + vd, p.position + vd, [KBody], 0b00000000000000000101)
		#if KBody.global_position.distance_squared_to(p.position) < 100*100:
		if result1 and result2 and "PlayerPlayer" == result1.collider.name+result2.collider.name:
			player_focused = p
			los = 1
			return los
	if los == 0: player_focused = null
	return los

func place_free(v):
	return KBody.test_move(transform, v)

func hm1_rotate(tur_dir, destdir, turnspeed):
	if (tur_dir > 359): tur_dir = 0
	if (tur_dir < 0): tur_dir = 359
	var dir = destdir - tur_dir
	if (dir > 180): dir = -(360-dir)
	if (dir < -180): dir = 360+dir

	if(dir <= turnspeed):
		tur_dir += dir
	else:
		tur_dir += sign(dir) * turnspeed
	return tur_dir

func enemy_shoot():
	#AAAA
	#MY NUTS
	gun.trigger_pressed=true
	
	pass


func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	get_node("PED_SPRITES").visible=true
	get_node("PED_SPRITES").set_enabled(true)


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	get_node("PED_SPRITES").visible=false
	get_node("PED_SPRITES").set_enabled(false)

