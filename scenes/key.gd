extends Control

#Used to load sounds and generally get strings for a note.
var note_map : Array = ["C", "C#",
						"D", "D#",
						"E",
						"F", "F#",
						"G", "G#",
						"A", "A#",
						"B"]

var keyboard_map : Dictionary = {
	#A       S        D        F        G       H        J        K        L        Ö        Ä
	100: 65, 101: 83, 102: 68, 103: 70, 104: 71, 105: 72, 106: 74, 107: 75, 108: 76, 109: 59, 110: 39,
		#Y       X        C        V        B        N       M        ,        .        -
		000: 90, 001: 88, 002: 67, 003: 86, 004: 66, 005: 78, 006: 77, 007: 44, 008: 46, 009: 47}



@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var unpressed : NinePatchRect = $Unpressed
@onready var pressed : NinePatchRect = $Pressed

@export var keyID : int
@export var octave : int
@export var noteID : int

#These should be more dynamically more centrally handled, 
#depended how pitch of keys are distributed in a octave.
#e.g. EDO31 instead of EDO12
var pitchup = 1.0594631
var pitchdown = 0.94387430765

#What is the distance between the sounds we have
#For now measured in 1/12 of octave
var notemodulo = 3
var notesinoctave = 12

var is_pressed : bool = false

func _ready() -> void:
	load_sound()

func warp_from_next(octave : int, noteID : int):
	#Returns warp_dict : Dictionary = {"warp-origin-octave" : 0, "warp-origin-node" : 0, "warp-factor" : 0.0}
	var mod = noteID % notemodulo
	var warp
	
	#Pitch up or down depending on whats closer.
	if mod <= notemodulo / 2.0:
		warp = mod
	else:
		warp = mod - notemodulo
	var unbound_origin_noteID = noteID - warp
	
	
	#Fix octave 
	var origin_octave = octave + floor(unbound_origin_noteID / notesinoctave)
	#Fix origin
	var origin_noteID = abs(unbound_origin_noteID % notesinoctave)
	
	#Get pitch warp-factor
	var warp_factor : float = 1.0
	if warp > 0:
		warp_factor = pitchup
	elif warp < 0:
		warp_factor = pitchdown
	for i in range(abs(warp) - 1):
		warp_factor *= warp_factor
	return {"warp-origin-octave" : origin_octave, "warp-origin-noteID" : origin_noteID, "warp-factor" : warp_factor}

func load_sound():
	#Find out from which sound sample we warp to this node.
	var warp_dict = warp_from_next(octave, noteID)
	
	var noteString = str(note_map[warp_dict.get("warp-origin-noteID")]) + str(warp_dict.get("warp-origin-octave"))
	audio_player.stream = load("res://audio/" + noteString + " Long V3.mp3")
	audio_player.pitch_scale = warp_dict.get("warp-factor")


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.physical_keycode == keyboard_map.get(keyID):
		if event.is_pressed() and !is_pressed:
			is_pressed = true
			unpressed.visible = false
			pressed.visible = true
			#Play audio
			audio_player.play()
		if event.is_released():
			is_pressed = false
			pressed.visible = false
			unpressed.visible = true
			#Stop audio
			audio_player.stop()
	#if event is InputEventKey:
	#	print(event.physical_keycode)
	#	var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
	#	var label = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
	#	print(keycode)
	#	print(label)
	#	print(OS.get_keycode_string(keycode))
	#	print(OS.get_keycode_string(label))
