extends AnimatedSprite2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if GAME.light_quality>=3:
		get_node("Light2D").enabled=false
	get_node("AnimationPlayer").play("New Anim")

func _process(_delta):
	get_node("Light2D").scale=Vector2(1,1)*modulate.a
# Called every frame. 'delta' is the elapsed time since the previous frame.
