extends Node

@export_category("ChessTile")
@export var chess_tile_scene:PackedScene
@export var chess_tile_meterial1:StandardMaterial3D
@export var chess_tile_meterial2:StandardMaterial3D

@export_category("Chess")
@export var chess_scene:PackedScene

const _CHESSTILEOFFSET = -2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_board()
	
	# DEBUG: temporarily create a chess
	var chess = ChessInst.new(Global.chess_loader.chess_name_list[1])
	
	var node = chess_scene.instantiate()
	node.chess = chess
	node.setup_ui()
	
	node.rotate_z(deg_to_rad(180))
	
	$Board.get_node("ChessTile00").add_child(node)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _init_board():
	for ir in range(Global.MAXR):
		for ic in range(Global.MAXC):
			var node = chess_tile_scene.instantiate()
			node.name = "ChessTile" + str(ir) + str(ic)
			
			node.r = ir
			node.c = ic
			
			# set material
			if (ir + ic) % 2 == 0:
				node.get_node("MeshInstance3D").get_mesh().set_material(chess_tile_meterial1)
			else:
				node.get_node("MeshInstance3D").get_mesh().set_material(chess_tile_meterial2)

			# set position
			node.position.x = _CHESSTILEOFFSET + ir
			node.position.z = _CHESSTILEOFFSET + ic
			
			$Board.add_child(node)
