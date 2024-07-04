extends Node

@export var chess_tile_scene:PackedScene
@export var chess_scene:PackedScene

const _CHESSTILEOFFSET = -2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_board()
	
	# DEBUG: temporarily create a chess
	var chess = ChessInst.new(Global.chess_loader.chess_name_list[1])
	
	var node = chess_scene.instantiate()
	node.setup_ui(chess)
	
	node.rotate_z(deg_to_rad(180))
	
	$Board.get_node("ChessTile00").add_child(node)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _init_board():
	for ir in range(Global.MAXR):
		for ic in range(Global.MAXC):
			var node = chess_tile_scene.instantiate()
			node.name = _get_tile_name_at_rc(ir, ic)
			
			node.r = ir
			node.c = ic
			
			# set material
			node.update_material(false)

			# set position, (0, 0) is the top-left corner
			node.position.x = _CHESSTILEOFFSET + ic
			node.position.z = _CHESSTILEOFFSET + ir
			
			node.connect("on_mouse_entered", _on_tile_mouse_entered)
			
			$Board.add_child(node)

func _get_tile_name_at_rc(r, c):
	return "ChessTile" + str(r) + str(c)

func _on_tile_mouse_entered(r, c):
	print(c)
