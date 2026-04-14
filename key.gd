extends Control

var anim_tex;

func _ready() -> void:
	anim_tex = $Front.texture as AnimatedTexture

func _unhandled_key_input(event: InputEvent) -> void:
	if(event.is_action_pressed("K")):
		anim_tex.current_frame = 1
	if(event.is_action_released("K")):
		anim_tex.current_frame = 0
