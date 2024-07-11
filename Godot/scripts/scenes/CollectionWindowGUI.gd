extends ColorRect

@export_category("Packed Scenes")
@export var chess_in_show_scene:PackedScene

@export_category("Variables")
@export var used_chess_label_font_size = 24
@export var add_used_chess_animation_time = 0.2

signal ok_button_pressed

@onready var all_chess_container = $VBoxContainer/HBoxContainer/AllChessScrollContainer/GridContainer
@onready var used_chess_container = $VBoxContainer/HBoxContainer/VBoxContainer/UsedChessScrollContainer
@onready var used_chess_container_inner = $VBoxContainer/HBoxContainer/VBoxContainer/UsedChessScrollContainer/VBoxContainer

const CHESS_NAME_PREFIX = "chess_name_"

var _is_in_animation = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ui_localization()
	
	# add chess to AllChess container
	for chess in Global.chess_loader.chess_name_list:
		var node = chess_in_show_scene.instantiate()
		node.chess = chess
		node.connect("chess_pressed", _on_chess_pressed)
		
		all_chess_container.add_child(node)
		node.setup_ui()
		
	# add chess to UsedChess container
	# locked chess first
	used_chess_container_inner.add_child(_get_node_used_chess("Duke", true))
	used_chess_container_inner.add_child(_get_node_used_chess("Footman", true))
	used_chess_container_inner.add_child(_get_node_used_chess("Footman", true))
	
	for chess in Global.chess_loader.chess_max_amount_dict:
		var amount = Global.chess_loader.chess_max_amount_dict[chess]
		
		# special rules for locked chess
		if (chess == "Duke"):
			amount -= 1
		
		if (chess == "Footman"):
			amount -= 2
			
		for i in range(amount):
			var node = _get_node_used_chess(chess, false)
	
			node.connect("pressed", _on_used_chess_pressed.bind(node))
			
			used_chess_container_inner.add_child(node)

func _setup_ui_localization():
	$VBoxContainer/HBoxContainer/VBoxContainer/ClearButton.text = tr("COLLECTION_CLEAR_ALL")
	$VBoxContainer/OKButton.text = tr("COLLECTION_CLOSE")

func _on_chess_pressed(node):
	if (not Global.is_local):
		return
	
	if (_is_in_animation):
		return
	
	var chess_name = node.chess
	
	# special rules for Duke
	if (chess_name == "Duke"):
		return
	
	Global.chess_loader.chess_max_amount_dict[chess_name] += 1
	
	var added_node = _add_used_chess(chess_name)
	
	# animation
	# https://forum.godotengine.org/t/can-i-take-a-screenshot-of-only-a-certain-area-of-my-scene/9193/2
	_is_in_animation = true
	
	var region = Rect2(node.global_position, node.size)
	var screenshot:Image = get_viewport().get_texture().get_image().get_region(region)
	
	var texture = ImageTexture.new()
	texture.set_image(screenshot)
	
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.modulate.a = 0.7
	sprite.centered = false
	sprite.global_position = node.global_position
	add_child(sprite)
	
	var x = used_chess_container.global_position.x + used_chess_container.size.x / 2
	var y = used_chess_container.global_position.y + used_chess_container.size.y / 2
	
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, add_used_chess_animation_time)
	tween.parallel().tween_property(sprite, "global_position", Vector2(x, y), add_used_chess_animation_time)
	tween.tween_callback(func():
		sprite.queue_free()
		_is_in_animation = false
	)

func _add_used_chess(chess_name):
	# first find where to put the new used chess
	var used_chess_container_inner_children = used_chess_container_inner.get_children()
	
	var cnt_locked_used_chess = 0
	
	var pos = 0
	for ix in used_chess_container_inner.get_child_count():
		var used_chess_node = used_chess_container_inner_children[ix]
		
		if (used_chess_node.is_in_group("locked_used_chess")):
			cnt_locked_used_chess += 1
			continue
		
		var used_chess_name = used_chess_node.text
		for group in used_chess_node.get_groups():
			if (CHESS_NAME_PREFIX in group):
				used_chess_name = group.replace(CHESS_NAME_PREFIX, "")
				break
		
		if (chess_name < used_chess_name):
			pos = ix
			break
	
		if (ix == used_chess_container_inner.get_child_count() - 1):
			pos = used_chess_container_inner.get_child_count()
	
	if (pos < cnt_locked_used_chess):
		pos = cnt_locked_used_chess
	
	var node = _get_node_used_chess(chess_name, false)
	
	node.connect("pressed", _on_used_chess_pressed.bind(node))
	
	used_chess_container_inner.add_child(node)
	used_chess_container_inner.move_child(node, pos)
	
	return node

func _on_used_chess_pressed(node):
	if (not Global.is_local):
		return
	
	node.queue_free()
	
	for group in node.get_groups():
		if (CHESS_NAME_PREFIX in group):
			var chess_name = group.replace(CHESS_NAME_PREFIX, "")
			Global.chess_loader.chess_max_amount_dict[chess_name] -= 1
			break

func _on_ok_button_pressed():
	if (_is_in_animation):
		return
		
	ok_button_pressed.emit()

func _get_node_used_chess(chess_name, is_locked):
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[chess_name]
	
	var node = Button.new()
	node.text = chess_model.get_tr_name()
	
	node.disabled = true if is_locked else false
	
	# set style
	node.add_theme_font_size_override("font_size", used_chess_label_font_size)
	
	var new_style = StyleBoxFlat.new()
	new_style.bg_color = Color.BLACK
	new_style.set_corner_radius_all(5)
	node.add_theme_stylebox_override("normal", new_style)
	
	node.add_to_group(CHESS_NAME_PREFIX + chess_name)
	
	if (is_locked):
		node.add_to_group("locked_used_chess")
	else:
		node.add_to_group("free_used_chess")
	
	return node

func _on_clear_button_pressed():
	get_tree().call_group("free_used_chess", "emit_signal", "pressed")
