extends Node

@export_category("ChessTile")
@export var chess_tile:PackedScene
@export var chess_tile_meterial1:StandardMaterial3D
@export var chess_tile_meterial2:StandardMaterial3D

const _CHESSTILEOFFSET = -2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	_init_board()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _init_board():
	for ir in range(Global.MAXR):
		for ic in range(Global.MAXC):
			var node = chess_tile.instantiate()
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
