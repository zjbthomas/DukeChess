extends Node

@export var chess_tile_scene:PackedScene
@export var chess_scene:PackedScene

const _CHESSTILEOFFSET = -2.5

var _state_cover_effects = []
var _hover_cover_effect_dict = {}

# variables for logic
var game = Game.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# init board GUI
	_init_board()
	
	# init game
	game.connect("add_chess", _on_add_chess)
	game.connect("state_cover_effect", _on_game_state_cover_effect)
	game.connect("game_message", _on_game_message)
	
	game.game_start()
	
func _on_add_chess(pos, chess:ChessInst):
	var node = chess_scene.instantiate()
	
	if not chess.is_front:
		node.rotate_z(deg_to_rad(180)) # show the back
	
	if not chess.player.is_main_player:
		node.rotate_y(deg_to_rad(180))
	
	var r = Global.n_to_rc(pos)[0]
	var c = Global.n_to_rc(pos)[1]
	
	$Board.get_node(_get_tile_name_at_rc(r, c)).add_child(node)
	node.setup_ui(chess)

func _on_game_state_cover_effect(cover_effect_dict):
	for n in cover_effect_dict:
		var node = _get_cover_effect_node(cover_effect_dict[n])
		
		var r = Global.n_to_rc(n)[0]
		var c = Global.n_to_rc(n)[1]
		$Board.get_node(_get_tile_name_at_rc(r, c)).add_child(node)
			
		_state_cover_effects.append(node)

func _get_cover_effect_node(color):
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color, 0.5)
	
	var mesh = PlaneMesh.new()
	mesh.size = Vector2(1, 1)
	mesh.set_material(material)
	
	var node = MeshInstance3D.new()
	node.set_mesh(mesh)
	node.position.y = 0.16
	
	return node

func _on_game_message(msg):
	$MainGUI/MarginContainer/Panel/MarginContainer/MessageLabel.text = msg

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
	var chess_back = game.get_chess_back(r, c)
	if (chess_back != null):
		$MainGUI.setup_chess_back(chess_back[0], chess_back[1])
		$MainGUI/CardBack.visible = true
	
	# DEBUG
	#var cover_effects = []
	#
	#for ir in range(Global.MAXR):
		#if (ir != r):
			#var material = StandardMaterial3D.new()
			#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			#material.albedo_color = Color(Color.YELLOW, 0.5)
			#
			#var mesh = PlaneMesh.new()
			#mesh.size = Vector2(1, 1)
			#mesh.set_material(material)
			#
			#var node = MeshInstance3D.new()
			#node.set_mesh(mesh)
			#node.position.y = 0.16
			#
			#$Board.get_node(_get_tile_name_at_rc(ir, c)).add_child(node)
			#
			#cover_effects.append(node)
			#
	#for ic in range(Global.MAXC):
		#if (ic != c):
			#var material = StandardMaterial3D.new()
			#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			#material.albedo_color = Color(Color.YELLOW, 0.5)
			#
			#var mesh = PlaneMesh.new()
			#mesh.size = Vector2(1, 1)
			#mesh.set_material(material)
			#
			#var node = MeshInstance3D.new()
			#node.set_mesh(mesh)
			#node.position.y = 0.16
			#
			#$Board.get_node(_get_tile_name_at_rc(r, ic)).add_child(node)
			#
			#cover_effects.append(node)
			#
	#_hover_cover_effect_dict[_get_tile_name_at_rc(r,c)] = cover_effects

func _on_tile_mouse_exited(r, c):
	$MainGUI/CardBack.visible = false
	
	var cover_effects = _hover_cover_effect_dict.get(_get_tile_name_at_rc(r,c))
	if (cover_effects != null):
		for ce in cover_effects:
			ce.queue_free()
		_hover_cover_effect_dict.erase(_get_tile_name_at_rc(r,c))
		
func _on_tile_mouse_pressed(r, c):
	# TODO: perform game op
	
	# remove cover effects for state if op can be performed
	for ce in _state_cover_effects:
		ce.queue_free()
	_state_cover_effects = []