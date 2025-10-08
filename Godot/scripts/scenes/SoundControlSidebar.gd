extends HBoxContainer

@onready var bgm_staus_label = $SoundControlPanel/MarginContainer/VBoxContainer/BGMHBoxContainer/BGMPanel/VBoxContainer/BGMStatusLabel
@onready var bgm_volumn_slider = $SoundControlPanel/MarginContainer/VBoxContainer/BGMHBoxContainer/BGMVolumnPanel/VBoxContainer/BGMVolumnSlider
@onready var bgm_volumn_label = $SoundControlPanel/MarginContainer/VBoxContainer/BGMHBoxContainer/BGMVolumnPanel/VBoxContainer/BGMVolumeLabel

@onready var fx_staus_label = $SoundControlPanel/MarginContainer/VBoxContainer/FXHBoxContainer/FXPanel/VBoxContainer/FXStatusLabel
@onready var fx_volumn_slider = $SoundControlPanel/MarginContainer/VBoxContainer/FXHBoxContainer/FXVolumnPanel/VBoxContainer/FXVolumnSlider
@onready var fx_volumn_label = $SoundControlPanel/MarginContainer/VBoxContainer/FXHBoxContainer/FXVolumnPanel/VBoxContainer/FXVolumeLabel

var _is_in_animation = false

var _is_bgm_code_change = false
var _is_fx_code_change = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$SoundControlPanel/MarginContainer.visible = false
	$SoundControlPanel.custom_minimum_size.x = 0
	
	# update labels as is_muted and volumns may change in different scenes
	_update_bgm_settings()
	_update_fx_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_entered():
	if (not _is_in_animation):
		_is_in_animation = true
	
		var tween = get_tree().create_tween()
		tween.tween_property($SoundControlPanel, "custom_minimum_size:x", 250, 0.1) # TODO: magic number
		
		tween.tween_callback(func():
			$SoundControlPanel/MarginContainer.visible = true
			_is_in_animation = false
		)

func _on_mouse_exited():
	if (not _is_in_animation):
		_is_in_animation = true
		
		$SoundControlPanel/MarginContainer.visible = false
		
		var tween = get_tree().create_tween()
		tween.tween_property($SoundControlPanel, "custom_minimum_size:x", 0, 0.05)
		
		_is_in_animation = false

func _on_bgm_button_pressed():
	BGM.switch()
	_update_bgm_settings()
	
func _on_fx_button_pressed():
	SoundEffect.switch()
	_update_fx_settings()
		
func _update_bgm_settings():
	if (!BGM.is_muted):
		bgm_staus_label.text = "[center]ON"
		bgm_volumn_slider.value = BGM.volumn
		bgm_volumn_label.text = str(BGM.volumn)
	else:
		bgm_staus_label.text = "[center]OFF"
		
		_is_bgm_code_change = true
		bgm_volumn_slider.value = 0
		_is_bgm_code_change = false
		
		bgm_volumn_label.text = "0"
		
func _update_fx_settings():
	if (!SoundEffect.is_muted):
		fx_staus_label.text = "[center]ON"
		fx_volumn_slider.value = SoundEffect.volumn
		fx_volumn_label.text = str(SoundEffect.volumn)
	else:
		fx_staus_label.text = "[center]OFF"
		
		_is_fx_code_change = true
		fx_volumn_slider.value = 0
		_is_fx_code_change = false
		
		fx_volumn_label.text = "0"

func _on_bgm_volumn_slider_value_changed(value):
	if (!_is_bgm_code_change):
		BGM.update_volumn(bgm_volumn_slider.value)
		_update_bgm_settings()


func _on_fx_volumn_slider_value_changed(value):
	if (!_is_fx_code_change):
		SoundEffect.update_volumn(fx_volumn_slider.value)
		_update_fx_settings()
