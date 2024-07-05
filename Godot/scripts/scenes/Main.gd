extends Node

@export var chess_tile_scene:PackedScene
@export var chess_scene:PackedScene

const _CHESSTILEOFFSET = -2.5

var _cover_effect_dict = {}

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
			node.connect("on_mouse_exited", _on_tile_mouse_exited)
			node.connect("on_mouse_pressed", _on_tile_mouse_pressed)
			
			$Board.add_child(node)

func _get_tile_name_at_rc(r, c):
	return "ChessTile" + str(r) + str(c)

func _on_tile_mouse_entered(r, c):
	# DEBUG
	var cover_effects = []
	
	for ir in range(Global.MAXR):
		if (ir != r):
			var material = StandardMaterial3D.new()
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color = Color(Color.YELLOW, 0.5)
			
			var mesh = PlaneMesh.new()
			mesh.size = Vector2(1, 1)
			mesh.set_material(material)
			
			var node = MeshInstance3D.new()
			node.set_mesh(mesh)
			node.position.y = 0.16
			
			$Board.get_node(_get_tile_name_at_rc(ir, c)).add_child(node)
			
			cover_effects.append(node)
			
	for ic in range(Global.MAXC):
		if (ic != c):
			var material = StandardMaterial3D.new()
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color = Color(Color.YELLOW, 0.5)
			
			var mesh = PlaneMesh.new()
			mesh.size = Vector2(1, 1)
			mesh.set_material(material)
			
			var node = MeshInstance3D.new()
			node.set_mesh(mesh)
			node.position.y = 0.16
			
			$Board.get_node(_get_tile_name_at_rc(r, ic)).add_child(node)
			
			cover_effects.append(node)
			
	_cover_effect_dict[_get_tile_name_at_rc(r,c)] = cover_effects

func _on_tile_mouse_exited(r, c):
	var cover_effects = _cover_effect_dict[_get_tile_name_at_rc(r,c)]
	for ce in cover_effects:
		ce.queue_free()
		
func _on_tile_mouse_pressed(r, c):
	print(r)
	print(c)
