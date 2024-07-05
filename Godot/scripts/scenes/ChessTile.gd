extends StaticBody3D

@export var meterial1:StandardMaterial3D
@export var meterial2:StandardMaterial3D

signal on_mouse_entered(r, c)
signal on_mouse_exited(r, c)
signal on_mouse_pressed(r, c)

var r
var c

# Called when the node enters the scene tree for the first time.
func _ready():
	$Selector.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_material(is_hover):
	if (is_hover):
		pass
	else:
		$MeshInstance3D.get_mesh().set_material(meterial1 if ((r + c) % 2 == 0) else meterial2)

func _on_mouse_entered():
	$Selector.visible = true
	
	on_mouse_entered.emit(r, c)

func _on_mouse_exited():
	$Selector.visible = false
	
	on_mouse_exited.emit(r, c)


func _on_input_event(camera, event, position, normal, shape_idx):
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				on_mouse_pressed.emit(r, c)
