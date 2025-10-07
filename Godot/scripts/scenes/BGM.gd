extends Node

var is_muted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play():
	$BGMPlayer.play()
	
func switch():
	if (!is_muted):
		$BGMPlayer.stop()
	else:
		$BGMPlayer.play()
		
	is_muted = !is_muted
