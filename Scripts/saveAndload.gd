extends Node
# Gets the score from the saved file
func load_score():
	var data = FileAccess.open("user://save_game.dat", FileAccess.READ)
	# If not present, return 0 (no high score)
	if data == null:
		data = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
		data.store_string("0")
		return str("0")
	var stored_score = data.get_as_text()
	return str(stored_score)

# Saves the score to the saved file
func save_score(stored_score, score): 
	var data = FileAccess.open("user://save_game.dat", FileAccess.READ_WRITE)
	# Only if the saved score is less than the current score
	if int(stored_score) < score:
		#data = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
		data.store_string(str(score))
	else: return
