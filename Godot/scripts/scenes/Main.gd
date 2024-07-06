extends Node

@export var chess_tile_scene:PackedScene
@export var chess_scene:PackedScene

@export var menu_scene:PackedScene

const _CHESSTILEOFFSET = -2.5

# variables for logic
var game = Game.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# init board GUI
	_init_board()
	
	# init game
	game.connect("add_chess", _on_add_chess)
	game.connect("state_cover_effect", _on_game_state_cover_effect)
	game.connect("hover_cover_effect", _on_game_hover_cover_effect)
	game.connect("show_menu", _on_game_show_menu)
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
	# first, remove previous cover effects
	get_tree().call_group("state_cover_effects", "queue_free")
	
	for n in cover_effect_dict:
		var node = _get_cover_effect_node(cover_effect_dict[n])
		
		var r = Global.n_to_rc(n)[0]
		var c = Global.n_to_rc(n)[1]
		$Board.get_node(_get_tile_name_at_rc(r, c)).add_child(node)
			
		node.add_to_group("state_cover_effects")
		
func _on_game_hover_cover_effect(pos, cover_effect_dict):
	var ori_r = Global.n_to_rc(pos)[0]
	var ori_c = Global.n_to_rc(pos)[1]
	
	for n in cover_effect_dict:
		var node = _get_cover_effect_node(cover_effect_dict[n])
		
		var r = Global.n_to_rc(n)[0]
		var c = Global.n_to_rc(n)[1]
		$Board.get_node(_get_tile_name_at_rc(r, c)).add_child(node)
			
		node.add_to_group(_get_hover_cover_effect_group_name_at_rc(ori_r, ori_c))

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

func _on_game_show_menu(pos, items):
	# DEBUG
	var r = Global.n_to_rc(pos)[0]
	var c = Global.n_to_rc(pos)[1]
	
	var center = get_viewport().get_camera_3d().unproject_position($Board.get_node(_get_tile_name_at_rc(r, c)).global_position)
	
	var menu = menu_scene.instantiate()
	menu.position = center
	
	menu.connect("on_button_pressed", _on_menu_button_pressed)
	
	$MainGUI.add_child(menu)
	
	menu.add_to_group("menu")
	
	menu.setup_buttons(items)

func _on_menu_button_pressed(item):
	var valid_op = game.perform_op(item, true)
	
	if (valid_op):
		get_tree().call_group("menu", "queue_free")
	
func _on_game_message(msg):
	if msg != null:
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

func _get_hover_cover_effect_group_name_at_rc(r, c):
	return "hover_cover_effects" + str(r) + str(c)

func _on_tile_mouse_entered(r, c):
	var chess_back = game.get_chess_back(r, c)
	if (chess_back != null):
		$MainGUI.setup_chess_back(chess_back[0], chess_back[1])
		$MainGUI/CardBack.visible = true
	
	game.emit_cover_effects(Global.rc_to_n(r, c), true)
	
func _on_tile_mouse_exited(r, c):
	$MainGUI/CardBack.visible = false
	
	get_tree().call_group(_get_hover_cover_effect_group_name_at_rc(r, c), "queue_free")
		
func _on_tile_mouse_pressed(r, c):
	var valid_op = game.perform_op(Global.rc_to_n(r, c), false)
