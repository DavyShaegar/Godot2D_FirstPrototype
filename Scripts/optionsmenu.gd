extends Control

@onready var music = $MarginContainer/CenterContainer/VBoxContainer/music

# Goes back to main menu
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

# Music ON/OFF
func _on_music_pressed():
	if Options.music == true:
		Options.music = false
		music.text = "Music: OFF"
	else:
		Options.music = true
		music.text = "Music: ON"

# Checks if music was already turned off
func _on_ready():
	if Options.music == true:
		music.text = "Music: ON"
	else:
		music.text = "Music: OFF"


#### ADD EXTERNAL FILES LATER WITH SCORES AND OPTIONS SAVED ####
