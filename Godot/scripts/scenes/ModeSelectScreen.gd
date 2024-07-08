extends ColorRect

@export var main_scene: PackedScene

func _on_local_mode_button_pressed():
	Global.is_local = true
	get_tree().change_scene_to_packed.bind(main_scene).call_deferred()

func _on_server_mode_button_pressed():
	Global.is_local = false
	get_tree().change_scene_to_packed.bind(main_scene).call_deferred()
