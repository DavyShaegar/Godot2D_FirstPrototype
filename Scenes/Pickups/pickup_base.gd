class_name Pickup
extends Area2D


@export_category("Pickup Options")
@export var is_active: bool
@export var is_respawning: bool
@export var respawning_time: float
@export var pickup_type: types
@export var pickup_value: int # (how much stat is increased, if increased)
@export var score_reward: int

@export var pickup_particle: GPUParticles2D

## Score: Treasure, just for points ---
## Health: Health pickups, for healing ---
## Upgrade: Character stats improvement ---
## Powerup: temporary buffs
enum types {score, health, upgrade, powerup}


func _set_particles() -> void:
	pass
	

func _respawn_handler() -> void:
	# No respawn = delete
	if is_respawning == false:
		queue_free()
	else: # After respawn time, reset the pickup
		await get_tree().create_timer(respawning_time).timeout
		is_active = true
		
		
func pickup(picked: CharacterBody2D) -> void:
	
	match pickup_type:
		0: # Score
			# Just adds score to the player
			if picked is Player:
				picked.add_score()
		1: # Health
			if picked.health < picked.max_health:
				
				if picked.health + pickup_value > picked.max_health:
					picked.health = picked.max_health
				else:
					picked.health += pickup_value
			else: # No pickup if health is max
				return
		2: # Upgrade
			pass
		3: # Powerup
			pass
	
	# Handles respawning
	_respawn_handler()

func _on_body_entered(body: Node2D) -> void:
	if is_active == false:
		return
		
	is_active = false
	pickup(body)
