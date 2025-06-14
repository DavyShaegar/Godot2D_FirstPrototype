class_name FlyingEye
extends Enemy

@export_category("Flying Eye Stats")
@export var attack_range: int = 40

func _set_raycast_target() -> void:
	# Sets the collision detector (raycast) to the char position if enemy is aggroed
	raycast.target_position = raycast.global_position.direction_to(entity_target.global_position) * attack_range if is_aggro == true else Vector2.ZERO


func _ready() -> void:
	_update_health_bar()


func _physics_process(delta: float) -> void:
	_ai_generic_behaviour(delta)
	_set_raycast_target()


func _on_los_area_body_exited(body: Node2D) -> void:
	if body == entity_target:
		time_to_forget.start()
		

func _on_forget_me_aggro_timeout() -> void:
	entity_target = null
	is_aggro = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "hit":
		set_state(States.idle)
	elif sprite.animation == "death":
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "attack":
		if sprite.frame == 6:
			if raycast.get_collider() != null:
				GlobalHandler.rando_pitch_audio_play(sound_attack, 0.85, 1.15)
				GlobalHandler.rando_pitch_audio_play(%Attack_2, 0.85, 1.15)
				raycast.get_collider().got_hit(damage)
	elif sprite.animation == "run":
		if sprite.frame == 7:
			GlobalHandler.rando_pitch_audio_play(sound_run, 0.85, 1.15)


func _on_animated_sprite_2d_animation_changed() -> void:
	if sprite.animation == "death":
		collision.queue_free()
		GlobalHandler.rando_pitch_audio_play(sound_death, 0.85, 1.15)
