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

#These should be more dynamically more centrally handled, 
#depended how pitch of keys are distributed in a octave.
#e.g. EDO31 instead of EDO12
var pitchup = 1.0594631
var pitchdown = 0.94387430765

#What is the distance between the sounds we have
#For now measured in 1/12 of octave
var keymodulo = 3
var keysinoctave = 12


func _ready() -> void:
	load_sound()

func warp_from_next(octave : int, keyID : int):
	#Returns warp_dict : Dictionary = {"warp-origin-octave" : 0, "warp-origin-node" : 0, "warp-factor" : 0.0}
	var mod = keyID % keymodulo
	var warp
	
	#Pitch up or down depending on whats closer.
	if mod <= keymodulo / 2.0:
		warp = mod
	else:
		warp = mod - keymodulo
	var unbound_origin_keyID = keyID - warp
	
	
	#Fix octave 
	var origin_octave = octave + floor(unbound_origin_keyID / keysinoctave)
	#Fix origin
	var origin_keyID = abs(unbound_origin_keyID % keysinoctave)
	
	#Get pitch warp-factor
	var warp_factor : float = 1.0
	if warp > 0:
		warp_factor = pitchup
	elif warp < 0:
		warp_factor = pitchdown
	for i in range(abs(warp) - 1):
		warp_factor *= warp_factor
	return {"warp-origin-octave" : origin_octave, "warp-origin-keyID" : origin_keyID, "warp-factor" : warp_factor}

func load_sound():
	#Find out from which sound sample we warp to this node.
	var warp_dict = warp_from_next(octave, keyID)
	
	var noteString = str(key_map[warp_dict.get("warp-origin-keyID")]) + str(warp_dict.get("warp-origin-octave"))
	audio_player.stream = load("res://audio/" + noteString + " Long V3.mp3")
	audio_player.pitch_scale = warp_dict.get("warp-factor")


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
