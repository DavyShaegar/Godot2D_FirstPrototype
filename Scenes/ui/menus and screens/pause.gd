extends MarginContainer

## This handles the pause menu


func _on_resume_pressed() -> void:
	get_tree().paused = false
	self.visible = false


func _on_exit_to_desk_pressed() -> void:
	get_tree().paused = false
	get_tree().quit(0)


func _on_exit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
