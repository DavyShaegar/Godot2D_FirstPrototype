extends Area2D

# Dagger upward movement
func _physics_process(delta):
	position.y -= 200 * delta

# Handles the collision with a target
func _on_body_entered(body):
	# Works only if target is Flying Eye
	if body.is_in_group("Eye"):
		# Plays the hit sound in a autoload scene (Dagger disappeares after hitting the target)
		Ambience.get_node("daggerhit").play()
		# Starts the normal enemy function
		get_node("/root/MainGame").enemydeath(body)
	# Destroys the dagger node
	queue_free()
