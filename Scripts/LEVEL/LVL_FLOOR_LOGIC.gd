extends Node2D


export var floor_clear=false
export var solid_collisions_list=[]
export(NodePath) var my_surface

var time_to_reset_navmap=0.1
var reset_navmap=true

func _ready():
	yield(get_tree().create_timer(0.01),"timeout")
	if visible==false:
		freeze_scene(self, true)

func _physics_process(_delta):
	floor_clear=true
	for i in get_children():
		if i in get_tree().get_nodes_in_group("Enemy_Parent"):
			floor_clear=false


func freeze_node(node, freeze):
	if (node is CollisionShape2D) or (node is CollisionPolygon2D):
		node.disabled=freeze
	if (node is RayCast2D):
		node.enabled=!freeze
	if (node.has_method("_manual_visiblity")):
		node._manual_visiblity(!freeze)
	if (node is RigidBody2D) && !(node in get_tree().get_nodes_in_group("Player")):
		node.linear_velocity=Vector2.ZERO
	if (node is WEAPON):
		node.pick_up=!freeze
	
	
	
#	if (node is Enemy):
#		node.active=true
#	if node is StaticBody2D:
#		if freeze:
#			solid_collisions_list.append([node.get_path(),node.collision_layer,node.collision_mask])
#			node.collision_layer=0
#			node.collision_mask=0
#		else:
#			for i in solid_collisions_list:
#				if i[0]==node.get_path():
#					node.collision_layer=i[1]
#					node.collision_mask=i[2]
	
	
	node.set_process(!freeze)
	node.set_physics_process(!freeze)




func freeze_scene(node, freeze,resetnavmap=false):
	freeze_node(node, freeze)
	for c in node.get_children():
		freeze_scene(c, freeze)
	reset_navmap=resetnavmap
	time_to_reset_navmap=1



