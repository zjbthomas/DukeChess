# https://github.com/adamviola/simple-free-look-camera/blob/master/camera.gd

extends Camera3D

const SENSITIVITY = 0.2

var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0

var _is_in_animation = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not _is_in_animation):
		_update_mouselook()
	
func _input(event):
	if (not _is_in_animation):
		# Receives mouse motion
		if event is InputEventMouseMotion:
			_mouse_position = event.relative
		
		# Receives mouse button input
		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
					Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if event.pressed else Input.MOUSE_MODE_VISIBLE)
				MOUSE_BUTTON_MIDDLE:
					if event.pressed:
						_total_pitch = 0.0
						
						_is_in_animation = true
						
						var time = 0.3 * (abs($"..".rotation.x - deg_to_rad(0)) / deg_to_rad(45)) # TODO: magic numbers

						var tween = get_tree().create_tween()
						tween.tween_property($"..", "rotation:x", deg_to_rad(0), time) 
						tween.tween_callback(func(): _is_in_animation = false)
					
# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		_mouse_position *= SENSITIVITY
		var pitch = _mouse_position.y
		_mouse_position = Vector2(0, 0)
		
		# Prevents looking too far
		pitch = clamp(pitch, -45 - _total_pitch, -_total_pitch)
		_total_pitch += pitch
	
		$"..".rotate_x(deg_to_rad(-pitch)) # same as $"..".rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
