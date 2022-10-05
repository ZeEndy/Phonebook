extends Node2D


@export var path_to_col: NodePath 
@export var locked: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	if path_to_col!="":
		get_node(path_to_col).disabled=!locked
