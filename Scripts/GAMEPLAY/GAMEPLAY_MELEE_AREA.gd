extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum at_types{
	downing,
	lethal
}
export(at_types) var attack_type
export var hit_sound = []
export var death_sprite = ""
export var death_lean_sprite = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_node("CollisionShape2D").disabled==false && get_node("../../../").state==0:
		var body = get_overlapping_bodies()
		for i in body:
			if i.get_parent()!=get_node("../../../"):
				var space_state = get_world_2d().direct_space_state
				var result = space_state.intersect_ray(get_node("../../../PED_COL").global_position, i.global_position,[],16,true,false)
				if result.size()==0:
					if i.get_parent().has_method("go_down") && attack_type=="downing":
						i.get_parent().go_down(get_node("../../../PED_COL").global_position.direction_to(i.global_position).angle())
					if i.get_parent().has_method("do_remove_health") && attack_type=="lethal":
						if !("Lean" in i.get_parent().sprites.get_node("Legs").animation):
							i.get_parent().do_remove_health(1,death_sprite,get_node("../../../PED_COL").global_position.direction_to(i.global_position).angle(),randi(),0.8)
							AudioManager.play_audio([false]+hit_sound,null,true,1,0,"SFX")
						else:
							i.get_parent().do_remove_health(1,death_lean_sprite,i.get_parent().sprites.get_node("Legs").global_rotation,randi(),0.8)
							AudioManager.play_audio([false]+hit_sound,null,true,1,0,"SFX")
						break
					if i.get_parent() is WINDOW:
						i.get_parent().destroy_window()

