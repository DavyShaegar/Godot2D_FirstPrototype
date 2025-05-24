extends Control

@export var menu_click: AudioStreamPlayer2D

func _set_settings() -> void:
	%EffectsSlider.value = AudioServer.get_bus_volume_db(1)
	%AmbienceSlider.value = AudioServer.get_bus_volume_db(2)
	%MusicSlider.value = AudioServer.get_bus_volume_db(3)
	
	if AudioServer.is_bus_mute(3):
		%MusicToggle.button_pressed = true


func _set_zero_volume(value: float, index: int) -> void:
	if value == -20.0:
		AudioServer.set_bus_mute(index, true)
	else: 
		AudioServer.set_bus_mute(index, false)
		

func _set_key_bindings() -> void:
	pass


func _ready() -> void:
	_set_settings()
	_set_key_bindings()


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
