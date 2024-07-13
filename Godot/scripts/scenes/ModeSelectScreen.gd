extends ColorRect

@export var load_scene: PackedScene

func _ready():
	# convert locale to inner ones
	var system_locale = TranslationServer.get_locale()
	for locale in Global.LOCALES:
		if (locale in system_locale):
			TranslationServer.set_locale(locale)
			
			system_locale = locale
			
			break
			
	TranslationServer.set_locale("en")
			
	# add localization options
	for ix in Global.LOCALES.size():
		$MarginContainer/LanguageContainer/OptionButton.add_item(Global.LOCALES[Global.LOCALES.keys()[ix]], ix)
		
		if (Global.LOCALES.keys()[ix] in system_locale):
			$MarginContainer/LanguageContainer/OptionButton.selected = ix
	
	_setup_ui_localization()
	
func _setup_ui_localization():
	$VBoxContainer/Label.text = tr("SELECT_MODE")
	$VBoxContainer/LocalModeButton.text = tr("SELECT_LOCAL")
	$VBoxContainer/AIEasyModeButton.text = tr("SELECT_AI_EASY")
	$VBoxContainer/AIHardModeButton.text = tr("SELECT_AI_HARD")
	$VBoxContainer/ServerModeButton.text = tr("SELECT_ONLINE")

func _on_local_mode_button_pressed():
	Global.is_local = true
	Global.is_ai = false
	get_tree().change_scene_to_packed.bind(load_scene).call_deferred()

func _on_ai_easy_mode_button_pressed():
	Global.is_local = true
	Global.is_ai = true
	
	Global.ai_depth = Global.AI_MODE.EASY
	
	get_tree().change_scene_to_packed.bind(load_scene).call_deferred()
	
func _on_ai_hard_mode_button_pressed():
	Global.is_local = true
	Global.is_ai = true
	
	Global.ai_depth = Global.AI_MODE.HARD
	
	get_tree().change_scene_to_packed.bind(load_scene).call_deferred()

func _on_server_mode_button_pressed():
	Global.is_local = false
	Global.is_ai = false
	get_tree().change_scene_to_packed.bind(load_scene).call_deferred()

func _on_option_button_item_selected(index):
	TranslationServer.set_locale(Global.LOCALES.keys()[index])
			
	_setup_ui_localization()
