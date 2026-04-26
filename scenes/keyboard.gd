extends Control

var keys : Array
@export var octaves = 8
@export var notesinoctave = 12

#Defines pressable keyarea.
@export var left_octavepos = 3
@export var left_notepos = 10
@export var right_octavepos = 5
@export var right_notepos = 3

@export var left_keyboardpos = 100
@export var right_keyboardpos = 110

#Defines which keys in an octave are white (0) and black (around 1, defining the exact positioning)
var keytype_map = [0, 0.8, 0, 1.2, 0, 0, 0.7, 0, 1, 0, 1.3, 0]

var packedwhitekey = preload("res://scenes/whitekey.tscn")
var packedblackkey = preload("res://scenes/blackkey.tscn")

var TEST_whitekeywidth = 19
var TEST_whitekeyheight = 97
var TEST_blackkeywidth = 14
var TEST_blackkeyheight = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	keys.resize(octaves*notesinoctave)
	init_spawn()



func init_spawn() -> void:
	#current white-key spawning position on x-axis
	var cur_xpos = 0
	
	#spawn keys from left to right
	var cur_octavepos = left_octavepos
	var cur_notepos = left_notepos
	var cur_keyboardpos = left_keyboardpos
	
	#Instantiate loop invariant
	var newkeypacked
	var key_xpos
	var cur_keywidth
	var cur_keyheight
	if keytype_map[cur_notepos] == 0:
		newkeypacked = packedwhitekey
		#Check if left bound is a black key:
		if keyboardpos_black(cur_keyboardpos):
			cur_keyboardpos = increment_keyboardpos(cur_keyboardpos, false)
			
		#Get position and size right
		key_xpos = cur_xpos #can spawn at leftpos since whitekey
		cur_keywidth = TEST_whitekeywidth
		cur_keyheight = TEST_whitekeyheight
	else:
		newkeypacked = packedblackkey
		#Check if left bound is a white key:
		if !keyboardpos_black(cur_keyboardpos):
			cur_keyboardpos = increment_keyboardpos(cur_keyboardpos, true)
		
		#Get position and size right
		cur_xpos += TEST_whitekeywidth #Skip to next whitekey pos
		key_xpos = cur_xpos - int((TEST_blackkeywidth / 2.0) * (2-keytype_map[cur_notepos])) #Shift spawning pos to the left
		cur_keywidth = TEST_blackkeywidth
		cur_keyheight = TEST_blackkeyheight
	
	spawn_packedkey(newkeypacked, cur_keyboardpos, cur_octavepos, cur_notepos, key_xpos, 0, cur_keywidth, cur_keyheight)
	
	#Invariant: All keys <= have been spawned
	while !(cur_octavepos == right_octavepos and cur_notepos == right_notepos):
		var inc = increment_notepos(cur_octavepos, cur_notepos)
		cur_octavepos = inc[0]
		cur_notepos = inc[1]
		
		if keytype_map[cur_notepos] == 0:
			if(!keyboardpos_black(cur_keyboardpos)):
				cur_xpos += TEST_whitekeywidth #Skip to next whitekey pos
			newkeypacked = packedwhitekey
			cur_keyboardpos = increment_keyboardpos(cur_keyboardpos, false)
			
			#Get position and size right
			key_xpos = cur_xpos
			cur_keywidth = TEST_whitekeywidth
			cur_keyheight = TEST_whitekeyheight
		else:
			newkeypacked = packedblackkey
			cur_keyboardpos = increment_keyboardpos(cur_keyboardpos, true)
			
			#Get position and size right
			cur_xpos += TEST_whitekeywidth #Skip to next whitekey pos
			key_xpos = cur_xpos - int((TEST_blackkeywidth / 2.0) * (2-keytype_map[cur_notepos])) #Shift spawning pos to the left
			cur_keywidth = TEST_blackkeywidth
			cur_keyheight = TEST_blackkeyheight
		
		#Make sure we have not escaped valid keyboard space
		assert(keyboardpos_less_equal(cur_keyboardpos, right_keyboardpos), "Escaped valid keyboard space. Either enlarge the keyboard space, or restrict the notespace!")
		spawn_packedkey(newkeypacked, cur_keyboardpos, cur_octavepos, cur_notepos, key_xpos, 0, cur_keywidth, cur_keyheight)


func increment_notepos(octave, note) -> Array[int]:
	note += 1
	if note >= notesinoctave:
		note = note % notesinoctave
		octave += 1
	return [octave, note]

func keyboardpos_black(pos) -> bool:
	return pos % 200 >= 100

func keyboardpos_less_equal(left, right) -> bool:
	#Order: 100 - 000 - 101 - 001 - 102 - 002
	return ((left % 100) <= (right % 100)) and (right - 100 != left)
	keys
func increment_keyboardpos(pos : int, new_key_black : bool) -> int:
	#Order: 100 - 000 - 101 - 001 - 102 - 002
	if (pos % 200 < 100 and !new_key_black) or (pos % 200 >= 100 and new_key_black):
		return pos + 1
	elif(pos % 200 < 100 and new_key_black):
		return pos + 101
	else:
		return pos - 100

func spawn_packedkey(packedkey, keyID, octave, noteID, x, y, width, height):
	if(keys[notesinoctave*octave+noteID] != null):
		push_warning("Key at oct: " + str(octave) + ", noteID: " + str(noteID) + " already spawned! Abort spawning.")
	var key = packedkey.instantiate()
	key.keyID = keyID
	key.octave = octave
	key.noteID = noteID
	
	key.position = Vector2(x, y)
	key.size = Vector2(width, height)
	
	add_child(key)
	keys[notesinoctave*octave+noteID] = key

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
