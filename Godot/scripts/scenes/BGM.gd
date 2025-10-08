extends Node

var is_muted = false

var DEFAULT_DB = -7
var MIN_DB = -40

var volumn: int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play():
	$BGMPlayer.play()
	
func switch():
	is_muted = !is_muted
	$BGMPlayer.stream_paused = is_muted
	
	if (!is_muted):
		update_volumn(volumn)

func update_volumn(volumn):
	self.volumn = volumn
	
	if (volumn == 0):
		is_muted = true
		$BGMPlayer.stream_paused = true
	else:
		is_muted = false
		$BGMPlayer.stream_paused = false
		
		$BGMPlayer.volume_db = lerp(MIN_DB, DEFAULT_DB, volumn / 100.0)
