extends Node

@export_category("Packed Scenes")
@export_file var mode_select_scene # TODO: to avoid cyclic dependency
@export var chess_tile_scene:PackedScene
@export var chess_scene:PackedScene
@export var menu_scene:PackedScene

@export_category("Variables")
@export var _chess_up_dist = 1.5
@export var _chess_up_down_time = 0.1
@export var _chess_move_time = 0.8
@export var _chess_flip_time = 0.5
@export var _chess_remove_time = 0.2

const _CHESS_TILE_OFFSET = -2.5

# variables for logic
var game = LocalGame.new() if Global.is_local else ServerGame.new(self)

var _is_in_animation = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ui_localization()
	
	# init board GUI
	_init_board()
	
	# init MainGUI
	$MainGUI/GridContainer/StartButton.disabled = false
	$MainGUI/ControlAreaControls/Player1ControlArea.visible = false
	$MainGUI/ControlAreaControls/Player2ControlArea.visible = false

	$MainGUI/GridContainer/BackButton.connect("pressed", _on_back_button_pressed)
	$MainGUI/GridContainer/StartButton.connect("pressed", _on_start_button_pressed)

	$MainGUI/ControlAreaControls/Player1ControlArea.connect("mouse_entered", _on_control_area_mouse_entered.bind(0))
	$MainGUI/ControlAreaControls/Player2ControlArea.connect("mouse_entered", _on_control_area_mouse_entered.bind(1))
	$MainGUI/ControlAreaControls/Player1ControlArea.connect("mouse_exited", _on_control_area_mouse_exited)
	$MainGUI/ControlAreaControls/Player2ControlArea.connect("mouse_exited", _on_control_area_mouse_exited)

	# init game
	game.connect("add_chess", _on_add_chess)
	game.connect("remove_chess", _on_remove_chess)
	game.connect("move_chess", _on_move_chess)
	
	game.connect("state_cover_effect", _on_game_state_cover_effect)
	game.connect("hover_cover_effect", _on_game_hover_cover_effect)
	game.connect("hover_control_area_cover_effect", _on_game_hover_control_area_cover_effect)
	game.connect("show_menu", _on_game_show_menu)
	game.connect("game_message", _on_game_message)
	game.connect("game_over", _on_game_over)
	
	if (not Global.is_local):
		game.connect("client_connected", _on_client_connected)
		game.connect("client_disconnected", _on_client_disconnected)
		game.connect("online_game_started", _on_online_game_started)
		game.connect("peer_disconnected", _on_peer_disconnected)

func _setup_ui_localization():
	$MainGUI/GridContainer/Label.text = tr("MAIN_MODE") + " " + (tr("SELECT_LOCAL") if Global.is_local else tr("SELECT_ONLINE"))

func _on_client_connected():
	$MainGUI/GridContainer/StartButton.disabled = true

func _on_online_game_started():
	$MainGUI/ControlAreaControls/Player1ControlArea.visible = true
	$MainGUI/ControlAreaControls/Player2ControlArea.visible = true

func _on_client_disconnected():
	$MainGUI/GridContainer/StartButton.disabled = false

func _on_peer_disconnected():
	# clear everything
	get_tree().call_group("chess", "queue_free")
	get_tree().call_group("all_hover_cover_effects", "queue_free")
	get_tree().call_group("state_cover_effects", "queue_free")

func _on_start_button_pressed():
	if (not _is_in_animation):
		# remove all chess
		get_tree().call_group("chess", "queue_free")
		
		await get_tree().create_timer(0.2).timeout # TODO: in case queue_free not finished
		
		if (Global.is_local):
			game.game_start()
			
			$MainGUI/ControlAreaControls/Player1ControlArea.visible = true
			$MainGUI/ControlAreaControls/Player2ControlArea.visible = true
		else:
			game.websocket_connect()

func _on_back_button_pressed():
	get_tree().change_scene_to_file.bind(mode_select_scene).call_deferred()

func _on_add_chess(pos, chess:ChessInst, is_no_effect):
	var node = chess_scene.instantiate()
	node.name = _get_chess_name_at_n(pos)

	node.connect("chess_collide", _on_chess_collide)
	
	if not chess.is_front:
		node.rotate_z(deg_to_rad(180)) # show the back
	
	if not chess.player.is_main_player:
		node.rotate_y(deg_to_rad(180))
	
	var r = Global.n_to_rc(pos)[0]
	var c = Global.n_to_rc(pos)[1]
	
	$Board.get_node(_get_tile_name_at_rc(r, c)).add_child(node)
	node.setup_ui(chess)
	
	node.add_to_group("chess")
	
	if (not is_no_effect):
		$Particles/LiveParticles.global_position = node.global_position
		$Particles/LiveParticles.restart()
	
	# add chess also means player list of chess update
	$MainGUI/AspectRatioContainer/PanelContainer/SummonInfo/Player1RemainLabel.text = _get_remaining_chess_text(game.player_list[0])
	$MainGUI/AspectRatioContainer/PanelContainer/SummonInfo/Player2RemainLabel.text = _get_remaining_chess_text(game.player_list[1])

func _on_chess_collide(node):
	$Particles/DeadParticles.global_position = node.global_position
	$Particles/DeadParticles.restart()
	
	node.queue_free()

func _on_remove_chess(pos):
	_is_in_animation = true
	
	var r = Global.n_to_rc(pos)[0]
	var c = Global.n_to_rc(pos)[1]
	var chess = $Board.get_node(_get_tile_name_at_rc(r, c)).get_node(_get_chess_name_at_n(pos))
	
	$Particles/DeadParticles.global_position = chess.global_position
	$Particles/DeadParticles.restart()
	
	var tween = get_tree().create_tween()
	tween.tween_property(chess, "scale", Vector3.ZERO, _chess_remove_time)
	tween.tween_callback(func():
		chess.queue_free()
		
		# remove chess may also update player list of chess
		$MainGUI/AspectRatioContainer/PanelContainer/SummonInfo/Player1RemainLabel.text = _get_remaining_chess_text(game.player_list[0])
		$MainGUI/AspectRatioContainer/PanelContainer/SummonInfo/Player1RemainLabel.text = _get_remaining_chess_text(game.player_list[1])
		
		_is_in_animation = false
	)
	
func _on_move_chess(src, dst, is_flip_during_move):
	_is_in_animation = true
	
	# first, remove all cover effects
	get_tree().call_group("all_hover_cover_effects", "queue_free")
	get_tree().call_group("state_cover_effects", "queue_free")
	
	var src_r = Global.n_to_rc(src)[0]
	var src_c = Global.n_to_rc(src)[1]
	var src_tile = $Board.get_node(_get_tile_name_at_rc(src_r, src_c))
	var src_chess = src_tile.get_node(_get_chess_name_at_n(src))
	
	# turn src_chess's monitoring to off
	src_chess.monitoring = false
	
	var ori_position_y = src_chess.position.y
	
	var dst_r = Global.n_to_rc(dst)[0]
	var dst_c = Global.n_to_rc(dst)[1]
	var dst_tile = $Board.get_node(_get_tile_name_at_rc(dst_r, dst_c))
	
	var tween = get_tree().create_tween()
	# 1: raise the chess
	tween.tween_property(src_chess, "position:y", ori_position_y + _chess_up_dist, _chess_up_down_time).set_trans(Tween.TRANS_QUART)
	
	# 2: move the chess
	tween.tween_property(src_chess, "global_position:x", dst_tile.global_position.x, _chess_move_time).set_trans(Tween.TRANS_QUART)
	tween.parallel().tween_property(src_chess, "global_position:z", dst_tile.global_position.z, _chess_move_time).set_trans(Tween.TRANS_QUART)

	# 3: flip the chess if needed
	if (is_flip_during_move):
		var rotation_z = deg_to_rad(0) if src_chess.rotation.z > 3 else deg_to_rad(180) # a rough estimiation
		tween.tween_property(src_chess, "rotation:z", rotation_z, _chess_flip_time).set_trans(Tween.TRANS_QUART)
		
	# 4: put down the chess
	tween.tween_property(src_chess, "position:y", ori_position_y, _chess_up_down_time).set_trans(Tween.TRANS_QUART)
	
	tween.tween_callback(func():
		# move src_chess to final tile
		src_tile.remove_child(src_chess)
		dst_tile.add_child(src_chess)
		src_chess.name = _get_chess_name_at_n(dst)
		
		# set local position to the one corresponding to the final tile
		src_chess.position.x = 0
		src_chess.position.z = 0
		
		# turn src_chess's monitoring back to on
		src_chess.monitoring = true
		
		_is_in_animation = false
		
		game.emit_after_move_animation()
	)
	
func _get_remaining_chess_text(player):
	var chess_amount_dict = player.chess_amount_dict
	var remaining_chess_text = ""
	for ix in chess_amount_dict.size():
		var chess_name = chess_amount_dict.keys()[ix]
		var amount = chess_amount_dict[chess_name]
		
		var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[chess_name]
		
		if (amount > 0):
			remaining_chess_text += chess_model.get_tr_name() + ":" + str(chess_amount_dict[chess_name]) + ' '

	return remaining_chess_text
			
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
		node.add_to_group("all_hover_cover_effects")

func _get_cover_effect_node(color):
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(color, 0.3)
	
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
		$MainGUI/MessageContainer/Panel/MessageLabel.text = msg

func _on_game_over():
	$MainGUI/GridContainer/StartButton.disabled = false

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
			node.position.x = _CHESS_TILE_OFFSET + ic
			node.position.z = _CHESS_TILE_OFFSET + ir
			
			node.connect("on_mouse_entered", _on_tile_mouse_entered)
			node.connect("on_mouse_exited", _on_tile_mouse_exited)
			node.connect("on_mouse_pressed", _on_tile_mouse_pressed)
			
			$Board.add_child(node)

func _get_tile_name_at_rc(r, c):
	return "ChessTile" + str(r) + str(c)
	
func _get_chess_name_at_n(n):
	return "Chess" + str(n)

func _get_hover_cover_effect_group_name_at_rc(r, c):
	return "hover_cover_effects" + str(r) + str(c)

func _on_tile_mouse_entered(r, c):
	if (not _is_in_animation):
		var chess_back = game.get_chess_back(r, c)
		if (chess_back != null):
			$MainGUI.setup_chess_back(chess_back[0], chess_back[1])
			$MainGUI/CardBack.visible = true
		
		game.emit_cover_effects(Global.rc_to_n(r, c))
	
func _on_tile_mouse_exited(r, c):
	$MainGUI/CardBack.visible = false
	
	get_tree().call_group(_get_hover_cover_effect_group_name_at_rc(r, c), "queue_free")
		
func _on_tile_mouse_pressed(r, c):
	if (not _is_in_animation):
		var valid_op = game.perform_op(Global.rc_to_n(r, c), false)

func _on_game_hover_control_area_cover_effect(cover_effect_dict):
	for n in cover_effect_dict:
		var node = _get_cover_effect_node(cover_effect_dict[n])
		
		var r = Global.n_to_rc(n)[0]
		var c = Global.n_to_rc(n)[1]
		$Board.get_node(_get_tile_name_at_rc(r, c)).add_child(node)
			
		node.add_to_group("all_hover_control_area_cover_effects")

func _on_control_area_mouse_entered(player_index):
	game.emit_control_area_cover_effects(game.player_list[player_index])

func _on_control_area_mouse_exited():
	get_tree().call_group("all_hover_control_area_cover_effects", "queue_free")
