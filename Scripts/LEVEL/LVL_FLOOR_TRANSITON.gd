extends Area2D

@export_node_path(SubViewport) var targetPath
@export_node_path(Area2D) var next_transiton
var x_pos = 0
@export var let_trough=false
@export var pull_out=false

#func _process(delta):
#	if let_trough==true:
#		$RayCast2D/AnimatedSprite.visible=true
#		x_pos+=0.75*delta
#		$RayCast2D/AnimatedSprite.playing=true
#		$RayCast2D/AnimatedSprite.position.x=-20-(abs((Vector2(5,0).rotated((deg_to_rad(-abs(x_pos))* 1.34deg_to_radrad(90))*500)).x))
#	else:
#		x_pos=0
#		$RayCast2D/AnimatedSprite.visible=false
#		$RayCast2D/AnimatedSprite.playing=false


func _physics_process(_delta):
	let_trough=get_parent().floor_clear
	$StaticBody2D/CollisionShape2D.disabled=let_trough
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.get_parent() is Player:
			if $StaticBody2D/CollisionShape2D.disabled==true:
				if b in get_tree().get_nodes_in_group("Player") && pull_out==false:
					b.get_parent().override_movement=true
					b.get_parent().movement((Vector2(160,0)).rotated(global_rotation),_delta)
#					b.linear_velocity=(Vector2(0.5,0)).rotated(global_rotation)
					GAME.fade=true
					if $RayCast2D.is_colliding()==true:
						var fart=b.get_parent()
						get_parent().remove_child(fart)
						get_node(targetPath).add_child(fart)
						get_parent().current=false
						get_node(targetPath).current=true
#						get_node(targetPath).switch_viewports()
						let_trough=true
						get_node(next_transiton).pull_out=true
						await get_tree().create_timer(0.02)
			else:
				b.get_parent().movement((Vector2(-160,0)).rotated(global_rotation),_delta)
				



func reparent(node: Node, new_parent: Node):
	var old_parent: Node = node.get_parent()
	old_parent.remove_child(node)
	new_parent.add_child(node)


func _on_NextFloor_body_exited(b):
	if b in get_tree().get_nodes_in_group("Player"):
		GAME.fade=false
		b.get_parent().override_movement=false
		if pull_out==true:
			get_tree().get_nodes_in_group("Level")[0]._save_checkpoint()
			pull_out=false
