class_name Skeleton
extends Enemy

"""# Specific check for ground height variation
# true if no change is detected by both the raycasts (both need to collide with ground)
# false if one of them doesn't detect ground
# may move to parent class
func _check_floor() -> bool:
	return true if %Right.is_colliding() and %Left.is_colliding() else false"""


func _ready() -> void:
	_update_health_bar()
	

func _physics_process(delta: float) -> void:
	
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	if !is_on_floor():
		velocity.y = move_toward(velocity.y, gravity, delta * gravity)
		
	_ai_generic_behaviour(delta)


# End of animation behvaiour
func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "hit":
		set_state(States.idle)
	elif sprite.animation == "death":
		await get_tree().create_timer(1.0).timeout
		queue_free()


# Attack sync
func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "attack":
		if sprite.frame == 6:
			if raycast.get_collider() != null:
				GlobalHandler.rando_pitch_audio_play(sound_attack, 0.85, 1.15)
				raycast.get_collider().got_hit(damage)


# Sounds sync
func _on_animated_sprite_2d_animation_changed() -> void:
	if sprite.animation == "death":
		collision.queue_free()
		
		GlobalHandler.rando_pitch_audio_play(sound_death, 0.85, 1.15)


func _on_los_area_body_exited(body: Node2D) -> void:
	if body == entity_target:
		time_to_forget.start()
		

func _on_forget_me_aggro_timeout() -> void:
	entity_target = null
	is_aggro = false
