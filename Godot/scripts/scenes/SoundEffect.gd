extends Node

const _STREAM_TYPE = {
	"checkmate": "res://musics//checkmate.mp3",
	"chess_move": "res://musics//chess_move.mp3",
	"countdown": "res://musics//countdown.mp3",
	"kill": "res://musics//kill.mp3",
	"notification_ok": "res://musics//notification_ok.mp3",
	"notification_error": "res://musics//notification_error.mp3",
	"win": "res://musics//win.mp3",
	"lose": "res://musics//lose.mp3",
}

var is_muted = false

var DEFAULT_DB = 0
var MIN_DB = -20

var volumn: int = 100

var is_in_priority = false

var _streams = {}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$SoundEffectPlayer.finished.connect(_on_fx_finished)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_fx_finished():
	if (is_in_priority):
		is_in_priority = false

func load_streams():
	for key in _STREAM_TYPE:
		_streams[key] = load(_STREAM_TYPE[key])
	
func play(name):
	if (!is_muted):
		if (!is_in_priority):
			$SoundEffectPlayer.stream = _streams.get(name)
			$SoundEffectPlayer.play()

func priority_play(name):
	if (!is_muted):
		is_in_priority = true
		$SoundEffectPlayer.stream = _streams.get(name)
		$SoundEffectPlayer.play()

func switch():
	is_muted = !is_muted
	
	if (is_muted):
		$SoundEffectPlayer.stop()
		is_in_priority = false # reset this to false as finished is NOT emitted when calling stop()	
	else:
		update_volumn(volumn)
		
func update_volumn(volumn):
	self.volumn = volumn
	
	if (volumn == 0):
		is_muted = true
		$SoundEffectPlayer.stop()
		is_in_priority = false # reset this to false as finished is NOT emitted when calling stop()	
	else:
		is_muted = false
		$SoundEffectPlayer.volume_db = lerp(MIN_DB, DEFAULT_DB, volumn / 100.0)
