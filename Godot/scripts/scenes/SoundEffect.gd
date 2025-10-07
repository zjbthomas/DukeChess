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

var _streams = {}
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_streams():
	for key in _STREAM_TYPE:
		_streams[key] = load(_STREAM_TYPE[key])
	
func play(name):
	if (!is_muted):
		if ($SoundEffectPlayer.playing == false):
			$SoundEffectPlayer.stream = _streams.get(name)
			$SoundEffectPlayer.play()

func priority_play(name):
	if (!is_muted):
		$SoundEffectPlayer.stream = _streams.get(name)
		$SoundEffectPlayer.play()

func switch():
	if (!is_muted):
		$SoundEffectPlayer.stop()
		
	is_muted = !is_muted
