extends ColorRect

@export var main_scene: PackedScene

func _ready():
	# add localization options
	var system_locale = TranslationServer.get_locale()
	for ix in Global.LOCALES.size():
		$MarginContainer/LanguageContainer/OptionButton.add_item(Global.LOCALES[Global.LOCALES.keys()[ix]], ix)
		
		if (Global.LOCALES.keys()[ix] in system_locale):
			$MarginContainer/LanguageContainer/OptionButton.selected = ix
	
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
	TranslationServer.set_locale(Global.LOCALES.keys()[index])
			
	_setup_ui_localization()
