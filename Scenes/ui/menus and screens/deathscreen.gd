extends Control

func update_score(score: int) -> void:
	%score.text = "Score: " + str(score)
	#%highscore.text = "Score: " + MaxScore
	
func _on_exit_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _on_exit_to_desk_pressed() -> void:
	get_tree().quit(0)
