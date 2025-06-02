extends Control

# All key bindings buttons
@onready var key_line_edits: Array[LineEdit] = [%left, %right, %jump, %attack, %throw, %pause]

# Sound chooser
@export var menu_click: AudioStreamPlayer2D

# Binding variables
var is_binding: bool = false
var current_key_line: LineEdit


# Sets the menu settings based on configuration file or, if not present, defaults
func _set_settings() -> void:
	%EffectsSlider.value = AudioServer.get_bus_volume_db(1)
	%AmbienceSlider.value = AudioServer.get_bus_volume_db(2)
	%MusicSlider.value = AudioServer.get_bus_volume_db(3)
	
	if AudioServer.is_bus_mute(3):
		%MusicToggle.button_pressed = true
		
	
	for lineEdit in key_line_edits:
		match lineEdit.name:
			"left":
				lineEdit.text = OS.get_keycode_string(InputMap.action_get_events("left")[0].physical_keycode)
			"right":
				lineEdit.text = OS.get_keycode_string(InputMap.action_get_events("right")[0].physical_keycode)
			"jump":
				lineEdit.text = OS.get_keycode_string(InputMap.action_get_events("jump")[0].physical_keycode)
			"attack":
				lineEdit.text = OS.get_keycode_string(InputMap.action_get_events("attack")[0].physical_keycode)
			"throw":
				lineEdit.text = OS.get_keycode_string(InputMap.action_get_events("throw")[0].physical_keycode)
			"pause":
				lineEdit.text = OS.get_keycode_string(InputMap.action_get_events("pause")[0].physical_keycode)


# Mutes audio bus if slider is at minimum
func _set_zero_volume(value: float, index: int) -> void:
	if value == -20.0:
		AudioServer.set_bus_mute(index, true)
	else: 
		AudioServer.set_bus_mute(index, false)


# Sets the new keybind
func _input(event: InputEvent) -> void:
	if is_binding == true:
		if event is InputEventKey:
			current_key_line.text = event.as_text_keycode()
			InputMap.action_erase_events(current_key_line.name)
			InputMap.action_add_event(current_key_line.name, event)
			is_binding = false
			current_key_line = null


# Sets the current key to assign the new keybind
func _set_key_bindings(event: InputEvent,linedit: LineEdit) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_binding = true
			current_key_line = linedit
	
	
func _ready() -> void:
	
	_set_settings()

	for lineEdit in key_line_edits:
		lineEdit.gui_input.connect(_set_key_bindings.bind(lineEdit))


func _on_effects_slider_value_changed(value: float) -> void:
	if menu_click.playing == false:
		menu_click.play()
	AudioServer.set_bus_volume_db(1, value)
	_set_zero_volume(value, 1)


func _on_ambience_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, value)
	_set_zero_volume(value, 2)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(3, value)
	_set_zero_volume(value, 3)


func _on_music_toggle_toggled(toggled_on: bool) -> void:
	menu_click.play()
	AudioServer.set_bus_mute(3, toggled_on)

# Saves the new options to config file
func _on_apply_pressed() -> void:
	pass # Replace with function body.
