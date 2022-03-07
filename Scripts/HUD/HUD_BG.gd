extends MeshInstance2D
tool

var dir = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scale=Vector2(get_viewport().size.y*2,get_viewport().size.x*2)
	dir += 0.25 * delta * 60
	var color2 = Color.black
	var color3 = Color.fuchsia
	var color4 = Color.aqua
	var color5 = Color.red
	var color1 = color2.linear_interpolate( 
		color3.linear_interpolate(
				color4,
				0.5 + 0.5 * cos(deg2rad(dir*3.12))
			).linear_interpolate(
			color5,
			0.125 + 0.125 * sin(deg2rad(dir*1.73))
		),
		0.75 + 0.25 * sin(deg2rad(dir*1.73))
	)
	texture.gradient.colors = [color2, color1]
