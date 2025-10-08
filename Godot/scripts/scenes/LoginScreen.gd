extends ColorRect

var _is_successful_login = false

var _login_timer = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ui_localization()
	
func _setup_ui_localization():
	$VBoxContainer/UsernameSplit/UsernameLabel.text = tr("LOGIN_USERNAME")
	$VBoxContainer/PasswordSplit/PasswordLabel.text = tr("LOGIN_PASSWORD")
	$VBoxContainer/LoginButton.text = tr("LOGIN_BUTTON")
	$VBoxContainer/BackButton.text = tr("LOGIN_BACK_BUTTON")
	$MarginContainer/Panel/VBoxContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_INIT")

func _on_option_button_item_selected(index):
	TranslationServer.set_locale(Global.LOCALES.keys()[index])
			
	_setup_ui_localization()

func _on_login_button_pressed():
	# reset timer
	_login_timer = 3
	$MarginContainer/Panel/VBoxContainer/TimerLabel.text = ""
	
	var username = $VBoxContainer/UsernameSplit/UsernameLineEdit.text
	var password = $VBoxContainer/PasswordSplit/PasswordLineEdit.text
	
	if username == "" or password == "":
		$MarginContainer/Panel/VBoxContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_INIT")
		SoundEffect.play("notification_error")
		return
	
	$VBoxContainer/UsernameSplit/UsernameLineEdit.editable = false
	$VBoxContainer/PasswordSplit/PasswordLineEdit.editable = false
	$VBoxContainer/LoginButton.disabled = true
	$VBoxContainer/BackButton.disabled = true
	
	var result = await Global.user.login(username, password)
	
	match result:
		Global.user.LOGIN_STATUS.NEW_LOGIN:
			_is_successful_login = true
			
			$MarginContainer/Panel/VBoxContainer/MsgLabel.text = "[center]" + Global.user.username + tr("LOGIN_MSG_NEW_USER")
			SoundEffect.play("notification_ok")
			
			$MarginContainer/Panel/VBoxContainer/TimerLabel.text = "[center]" + str(_login_timer)
			$Timer.start()
		Global.user.LOGIN_STATUS.WRONG_PASSWORD:
			_is_successful_login = false
			
			$MarginContainer/Panel/VBoxContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_PASSWORD_INCORRECT")
			SoundEffect.play("notification_error")
			
			$VBoxContainer/UsernameSplit/UsernameLineEdit.editable = true
			$VBoxContainer/PasswordSplit/PasswordLineEdit.editable = true
			$VBoxContainer/LoginButton.disabled = false
			$VBoxContainer/BackButton.disabled = false
		Global.user.LOGIN_STATUS.SUCCESSFUL_LOGIN:
			_is_successful_login = true
			
			$MarginContainer/Panel/VBoxContainer/MsgLabel.text = "[center]" + Global.user.username + tr("LOGIN_MSG_OLD_USER")
			SoundEffect.play("notification_ok")
			
			$MarginContainer/Panel/VBoxContainer/TimerLabel.text = "[center]" + str(_login_timer)
			$Timer.start()
		Global.user.LOGIN_STATUS.SERVER_ERROR:
			_is_successful_login = false
			
			$MarginContainer/Panel/VBoxContainer/MsgLabel.text = "[center]" + tr("LOGIN_MSG_SERVER_DOWN")
			SoundEffect.play("notification_error")
			
			$VBoxContainer/UsernameSplit/UsernameLineEdit.editable = true
			$VBoxContainer/PasswordSplit/PasswordLineEdit.editable = true
			$VBoxContainer/LoginButton.disabled = false
			$VBoxContainer/BackButton.disabled = false

func _on_timer_timeout():
	_login_timer -= 1
	$MarginContainer/Panel/VBoxContainer/TimerLabel.text = "[center]" + str(_login_timer)
	SoundEffect.play("countdown")
	
	if (_login_timer == 0 and _is_successful_login):
		$Timer.stop()
		
		get_tree().change_scene_to_file.bind("res://scenes/Main.tscn").call_deferred()

func _on_back_button_pressed():
	get_tree().change_scene_to_file.bind("res://scenes//ModeSelectScreen.tscn").call_deferred()
