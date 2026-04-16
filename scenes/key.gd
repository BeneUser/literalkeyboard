extends Control


var key_map : Array = ["C", "C#",
						"D", "D#",
						"E",
						"F", "F#",
						"G", "G#",
						"A", "A#",
						"B"]



@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var unpressed : NinePatchRect = $Unpressed
@onready var pressed : NinePatchRect = $Pressed

@export var key : String
@export var octave : int
@export var keyID : int



func _ready() -> void:
	var noteString = str(key_map[keyID]) + str(octave)
	audio_player.stream = load("res://audio/" + noteString + " Long V3.mp3")
	

func _unhandled_key_input(event: InputEvent) -> void:
	if(event.is_action_pressed(key)):
		unpressed.visible = false
		pressed.visible = true
		#Play audio
		audio_player.play()
	if(event.is_action_released(key)):
		pressed.visible = false
		unpressed.visible = true
		audio_player.stop()
