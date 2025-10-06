extends ColorRect

@export var mode_select_scene: PackedScene

var _is_successful_login = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# convert locale to inner ones
	var system_locale = TranslationServer.get_locale()
	for locale in Global.LOCALES:
		if (locale in system_locale):
			TranslationServer.set_locale(locale)
			
			system_locale = locale
			
			break
			
	# add localization options
	for ix in Global.LOCALES.size():
		$LanguageMarginContainer/LanguageContainer/OptionButton.add_item(Global.LOCALES[Global.LOCALES.keys()[ix]], ix)
		
		if (Global.LOCALES.keys()[ix] in system_locale):
			$LanguageMarginContainer/LanguageContainer/OptionButton.selected = ix

	_setup_ui_localization()
	
func _setup_ui_localization():
	$VBoxContainer/UsernameSplit/UsernameLabel.text = tr("LOGIN_USERNAME")
	$VBoxContainer/PasswordSplit/PasswordLabel.text = tr("LOGIN_PASSWORD")
	$VBoxContainer/LoginButton.text = tr("LOGIN_BUTTON")
	$MarginContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_INIT") + "[center]"

func _on_option_button_item_selected(index):
	TranslationServer.set_locale(Global.LOCALES.keys()[index])
			
	_setup_ui_localization()

func _on_login_button_pressed():
	var username = $VBoxContainer/UsernameSplit/UsernameLineEdit.text
	var password = $VBoxContainer/PasswordSplit/PasswordLineEdit.text
	
	if username == "" or password == "":
		$MarginContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_INIT") + "[center]"
		return
	
	$VBoxContainer/UsernameSplit/UsernameLineEdit.editable = false
	$VBoxContainer/PasswordSplit/PasswordLineEdit.editable = false
	$VBoxContainer/LoginButton.disabled = true
	
	var result = await Global.user.login(username, password)
	
	match result:
		Global.user.LOGIN_STATUS.NEW_LOGIN:
			_is_successful_login = true
			
			$MarginContainer/MsgLabel.text = "[center]" + Global.user.username + tr("LOGIN_MSG_NEW_USER") + "[center]"
			
			$Timer.start()
		Global.user.LOGIN_STATUS.WRONG_PASSWORD:
			_is_successful_login = false
			
			$MarginContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_PASSWORD_INCORRECT") + "[center]"
			
			$VBoxContainer/UsernameSplit/UsernameLineEdit.editable = true
			$VBoxContainer/PasswordSplit/PasswordLineEdit.editable = true
			$VBoxContainer/LoginButton.disabled = false
		Global.user.LOGIN_STATUS.SUCCESSFUL_LOGIN:
			_is_successful_login = true
			
			$MarginContainer/MsgLabel.text = "[center]" + Global.user.username + tr("LOGIN_MSG_OLD_USER") + "[center]"
			
			$Timer.start()
		Global.user.LOGIN_STATUS.SERVER_ERROR:
			_is_successful_login = false
			
			$MarginContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_SERVER_DOWN") + "[center]"
			
			$VBoxContainer/UsernameSplit/UsernameLineEdit.editable = true
			$VBoxContainer/PasswordSplit/PasswordLineEdit.editable = true
			$VBoxContainer/LoginButton.disabled = false

func _on_timer_timeout():
	if (_is_successful_login):
		get_tree().change_scene_to_packed.bind(mode_select_scene).call_deferred()
