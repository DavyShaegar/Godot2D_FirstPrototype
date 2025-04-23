extends Control

# Restart game
func _on_restart_pressed():
	get_tree().change_scene_to_file("res://node_2d.tscn")

# Goes back to the main menu
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")

# Saves the new high score, if higher, and shows current and high score
func _on_tree_entered():
	
	var game = get_node("/root/MainGame")
	var stored_score = SaveAndload.load_score()
	
	SaveAndload.save_score(stored_score, game.score)
	stored_score = SaveAndload.load_score()
	
	get_node("scorescontainer/VBoxContainer/score").text = "Score: " + str(game.score)
	get_node("scorescontainer/VBoxContainer/highscore").text = "High Score: " + stored_score
