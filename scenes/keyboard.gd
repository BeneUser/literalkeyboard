extends Control

var keys : Array
@export var octaves = 8
@export var notesinoctave = 12

#Defines pressable keyarea.
@export var left_octavepos = 3
@export var left_notepos = 10
@export var right_octavepos = 5
@export var right_notepos = 3

#Defines which keys in an octave are white (0) and black (1)
var keytype_map = [0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	keys.resize(octaves*notesinoctave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
