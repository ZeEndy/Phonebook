extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ready=false
var change_z=0.15
var heat=1





# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	applied_torque=(linear_velocity.length())*5
	if change_z>0:
		change_z-=delta
	else:
		ready=true
		z_index=-2
	#transfer sprite on surface when low enough speed
	if linear_velocity.length()<0.001 && ready==true:
		var sprite = get_node("Sprite")
		get_parent().get_node(get_parent().my_surface).add_to_surface(sprite,global_position,global_rotation)
		if get_node_or_null("Sprite")==null:
			queue_free()
