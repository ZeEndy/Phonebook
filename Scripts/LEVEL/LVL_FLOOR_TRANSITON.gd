extends Area2D

export(NodePath) var targetPath
export(NodePath) var next_transiton
var x_pos = 0
export var let_trough=false
export var pull_out=false

#func _process(delta):
#	if let_trough==true:
#		$RayCast2D/AnimatedSprite.visible=true
#		x_pos+=0.75*delta
#		$RayCast2D/AnimatedSprite.playing=true
#		$RayCast2D/AnimatedSprite.position.x=-20-(abs((Vector2(5,0).rotated((deg2rad(-abs(x_pos))* 1.34 + deg2rad(90))*500)).x))
#	else:
#		x_pos=0
#		$RayCast2D/AnimatedSprite.visible=false
#		$RayCast2D/AnimatedSprite.playing=false


func _physics_process(_delta):
	let_trough=get_parent().floor_clear
	if get_parent().visible==true:
		$StaticBody2D/CollisionShape2D.disabled=let_trough
		var bodies = get_overlapping_bodies()
		for b in bodies:
			if b.get_parent() is Player:
				if $StaticBody2D/CollisionShape2D.disabled==true:
					if b in get_tree().get_nodes_in_group("Player") && pull_out==false:
						b.get_parent().ability_override_movement=true
						b.get_parent().movement((Vector2(160,0)).rotated(global_rotation),_delta)
	#					b.linear_velocity=(Vector2(0.5,0)).rotated(global_rotation)
						get_tree().get_nodes_in_group("GLOBAL")[0].fade=true
						if $RayCast2D.is_colliding()==true:
							get_parent().visible=false
							get_parent().freeze_scene(get_parent(), true)
							var fart=b.get_parent()
							get_parent().remove_child(fart)
							get_node(targetPath).add_child(fart)
							var cursor=get_tree().get_nodes_in_group("Cursor")[0]
							get_parent().remove_child(cursor)
							get_node(targetPath).add_child(cursor)
							get_node(targetPath).visible=true
							let_trough=true
							get_node(targetPath).freeze_scene(get_node(targetPath), false)
							get_node(next_transiton).pull_out=true
							yield(get_tree().create_timer(0.02),"timeout")
							get_tree().get_nodes_in_group("NavMap")[0].nav_map_up_to_date=false
				else:
					b.get_parent().movement((Vector2(-160,0)).rotated(global_rotation),_delta)
				



func reparent(node: Node, new_parent: Node):
	var old_parent: Node = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)


func _on_NextFloor_body_exited(b):
	if b in get_tree().get_nodes_in_group("Player"):
		get_tree().get_nodes_in_group("GLOBAL")[0].fade=false
		b.get_parent().ability_override_movement=false
		if pull_out==true:
			get_tree().get_nodes_in_group("Level")[0]._save_checkpoint()
			pull_out=false
