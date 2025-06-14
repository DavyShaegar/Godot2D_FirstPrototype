class_name Pickup
extends Area2D


@export_category("Pickup Options")
@export var is_active: bool
@export var is_respawning: bool
@export var respawning_time: float
@export var pickup_type: types
@export var pickup_value: int # (how much stat (ammo and health too) is increased, if increased)
@export var score_reward: int 

@export var pickup_particle: GPUParticles2D
@export var pickup_sound: AudioStream = null

## Score: Treasure, just for points ---
## Health: Health pickups, for healing ---
## Ammo: Well... ---
## Upgrade: Character stats improvement ---
## Powerup: temporary buffs
enum types {score, health, ammo, upgrade, powerup}

# Position for audio stream
var sound_pos: Vector2

func _set_particles() -> void:
	pass
	
	
# Creates and plays sound from a sibling node
# Sound varies based on type of pickup
func _create_sound() -> void:
	var sound := AudioStreamPlayer2D.new()
	sound.stream = pickup_sound
	sound.bus = "SFX"
	sound.global_position = sound_pos
	add_sibling(sound)
	sound.play()
	# Connects this new node to a global function
	# this pickup class will be deleted before the sound's end, so this script will be lost
	sound.finished.connect(GlobalHandler.global_remove.bind(sound))


func _respawn_handler() -> void:
	# No respawn = delete
	if is_respawning == false:
		queue_free()
	else: # After respawn time, reset the pickup
		await get_tree().create_timer(respawning_time).timeout
		is_active = true
		
		
func pickup(picked: CharacterBody2D) -> void:
	# Just adds score to the player
	picked.add_score(score_reward)
		
	match pickup_type:
		0: # Score
			GlobalHandler.show_floating_pickup(picked, types.score, score_reward)
		1: # Health
			if picked.health < picked.max_health:
				
				# for difference to get amount healed
				var previous_health: int = picked.health
				
				if picked.health + pickup_value > picked.max_health:
					picked.health = picked.max_health
				else:
					picked.health += pickup_value
				
				# Shows the floating text
				GlobalHandler.show_floating_pickup(picked, types.health, picked.health - previous_health)
				
			else: # No pickup if health is max
				is_active = true # Reactivates the pickup
				return
		2: # Ammo
			picked.dagger_count += pickup_value
			GlobalHandler.show_floating_pickup(picked, types.ammo ,pickup_value)
		3: # Upgrade
			pass
		4: # Powerup
			pass
	
	# Plays sound with a sibling node
	_create_sound()
	# Handles respawning (either respawning or one-shot pickup)
	_respawn_handler()

func _on_body_entered(body: Node2D) -> void:
	if is_active == false or body is not Player:
		return
		
	is_active = false
	sound_pos = body.global_position
	pickup(body)
