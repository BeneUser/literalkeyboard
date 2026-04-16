extends Control

@export var key : String
var unpressed : NinePatchRect
var pressed : NinePatchRect

func _ready() -> void:
	unpressed = $Unpressed
	pressed = $Pressed

func _unhandled_key_input(event: InputEvent) -> void:
	if(event.is_action_pressed(key)):
		unpressed.visible = false
		pressed.visible = true
	if(event.is_action_released(key)):
		pressed.visible = false
		unpressed.visible = true
