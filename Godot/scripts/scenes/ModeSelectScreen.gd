extends ColorRect

@export var main_scene: PackedScene

func _ready():
	match TranslationServer.get_locale():
		"en":
			$MarginContainer/LanguageContainer/OptionButton.selected = 0
		"zh", "zh_CN":
			$MarginContainer/LanguageContainer/OptionButton.selected = 1
	
	_setup_ui_localization()
	
func _setup_ui_localization():
	$VBoxContainer/Label.text = tr("SELECT_MODE")
	$VBoxContainer/LocalModeButton.text = tr("SELECT_LOCAL")
	$VBoxContainer/ServerModeButton.text = tr("SELECT_ONLINE")

func _on_local_mode_button_pressed():
	Global.is_local = true
	get_tree().change_scene_to_packed.bind(main_scene).call_deferred()

func _on_server_mode_button_pressed():
	Global.is_local = false
	get_tree().change_scene_to_packed.bind(main_scene).call_deferred()


func _on_option_button_item_selected(index):
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("zh")
		_:
			TranslationServer.set_locale("en")
			
	_setup_ui_localization()
