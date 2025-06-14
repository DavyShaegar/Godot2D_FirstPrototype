extends Node
## Global Script
## This stores some basic global functions

# Floating text for multiple uses
# if floating text damage:
# color based on who's getting hit (player = red, enemy = white)
# if floating heal: green
@onready var floating: PackedScene = load("res://Scenes/ui/floatingtext.tscn")

#region Tweens
## screen fade in
func fade_in(canvas: CanvasModulate, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(canvas, "color", Color(1, 1, 1, 1), duration)


## Screen fade out
func fade_out(canvas: CanvasModulate, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(canvas, "color", Color(0, 0, 0, 1), duration)


## Tween for floating text after player heals
func _floating_pickup_effect(label: Label) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 0.4).from(Color(1,1,1,0))
	tween.parallel().tween_property(label, "global_position", label.global_position + Vector2(0.0, -30.0), 0.8).from_current()
	tween.tween_property(label, "global_position", label.global_position + Vector2(0.0, -40.0), 0.4)
	tween.parallel().tween_property(label, "modulate", Color(1, 1, 1, 0), 0.4)
	
	await tween.finished
	label.queue_free()


## Tween for floating text after an entity takes damage
func _floating_damage_effect(damage_node: Label) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(5.0, -10.0), 0.25).from_current()
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(-5.0, -20.0), 0.25)
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(5.0, -30.0), 0.25)
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(5.0, -40.0), 0.4)
	tween.parallel().tween_property(damage_node, "modulate", Color(1, 1, 1, 0), 0.4)
	
	await tween.finished
	damage_node.queue_free()
	
#endregion
	
	
func show_floating_damage(entity_hit: CharacterBody2D, damage: int) -> void:
	var in_floating_damage: Label = floating.instantiate()
	
	if entity_hit is Player:
		in_floating_damage.add_theme_color_override("font_color", Color.RED)
	elif entity_hit is Enemy:
		in_floating_damage.add_theme_color_override("font_color", Color.GRAY)
		
	in_floating_damage.text = "- " + str(damage)
	in_floating_damage.global_position = entity_hit.global_position - Vector2(0, 50)
	add_child(in_floating_damage)
	_floating_damage_effect(in_floating_damage)


# Shows floating text based on pickup
func show_floating_pickup(player: Player, pickup_type: Pickup.types, amount: int) -> void:
	var in_floating: Label = floating.instantiate()
	match pickup_type:
		0: # Treasure
			in_floating.add_theme_color_override("font_color", Color.YELLOW)
			in_floating.text = "+" + str(amount) + " points"
		1: # Health
			in_floating.add_theme_color_override("font_color", Color.GREEN)
			in_floating.text = "+" + str(amount)
		2: # Ammo
			in_floating.add_theme_color_override("font_color", Color.GRAY)
			in_floating.text = "+" + str(amount) + " daggers"
		3: # Upgrade
			pass
		4: # Powerup
			pass
			
	in_floating.global_position = player.global_position - Vector2(0, 50)
	add_child(in_floating)
	_floating_pickup_effect(in_floating)


# Plays an audio with a random pitch of a value between 2 ranges
# Then resets the pitch
func rando_pitch_audio_play(Audio: AudioStreamPlayer2D, from_range: float, to_range: float) -> void:
	var og_pitch_scale: float = Audio.pitch_scale
	print("Normal pitch: ", og_pitch_scale)
	Audio.pitch_scale = randf_range(from_range, to_range)
	print("New pitch: ", Audio.pitch_scale)
	Audio.play()
	
	# Waits for the audio to finish properly
	await  Audio.finished
	Audio.pitch_scale = og_pitch_scale


# Removes nodes (use signals and connect to this function)
func global_remove(node: Node2D) -> void:
	print(node.name, " --- DELETED")
	node.queue_free()
	

## DEBUG
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug_reset"):
		get_tree().reload_current_scene()
