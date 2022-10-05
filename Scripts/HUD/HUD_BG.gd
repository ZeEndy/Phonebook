extends MeshInstance2D
@tool

var dir = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale=Vector2(get_viewport().size.y*2,get_viewport().size.x*2)
	dir += 0.25 * delta * 60
	var color2 = Color.BLACK
	var color3 = Color.FUCHSIA
	var color4 = Color.AQUA
	var color5 = Color.RED
	var color1 = color2.lerp( 
		color3.lerp(
				color4,
				0.5 + 0.5 * cos(deg_to_rad(dir*3.12))
			).lerp(
			color5,
			0.125 + 0.125 * sin(deg_to_rad(dir*1.73))
		),
		0.75 + 0.25 * sin(deg_to_rad(dir*1.73))
	)
	texture.gradient.colors = [color2, color1]
