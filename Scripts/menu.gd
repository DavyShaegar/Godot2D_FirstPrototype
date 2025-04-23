extends Control

# Starts the game
func _on_start_pressed():
	get_tree().change_scene_to_file("res://node_2d.tscn")

# Exits the game
func _on_exit_pressed():
	get_tree().quit()

# Opens the options menu
func _on_options_pressed():
	get_tree().change_scene_to_file("res://optionsmenu.tscn")

# Checks saved high score
func _on_highscore_ready():
	get_node("CenterContainer/score/highscore").text = "High Score: " + SaveAndload.load_score()
