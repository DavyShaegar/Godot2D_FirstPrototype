class_name Enemy
extends CharacterBody2D

## This is the base enemy class
## This stores all the default attributes and methods
## Some will be overridden

@export_category("Enemy Stats")
@export var health: int
@export var max_health: int
@export var damage: int
@export var speed: int
@export var score_reward: int


@export_category("Enemy Nodes")
@export var sprite: AnimatedSprite2D # Animation
@export var raycast: RayCast2D # Checks collision with player and level geometry
@export var nav: NavigationAgent2D # Navigation for enemy movement (especially flying ones)
@export var collision: CollisionShape2D # Remove this when death animation plays so that the body won't be an obstable
@export var los: Area2D # Line of sight. Handles entity perception
@export var time_to_forget: Timer # Time for the entity to reset aggro if target is outside reach
@export var health_bar: ProgressBar


# States explanation:
# idle - When player is not aggroed
# run - Player is aggroed
# patrol - Enemy is moving without aggro
# attack - Enemy is attacking (the player)
# hit - Enemy has been hit (stun)
# death - enemy is dying
enum States {idle, run, attack, hit, death}

@export_category("Enemy States")
@export var current_state: States = States.idle # Initialized as Idle
@export var is_flying: bool # Identifier for flying enemies... or not
@export var is_patrolling: bool # Enemy is in a partrol routine (affects idle navigation)
@export var is_aggro: bool # If enemy is actively chasing the player
@export var entity_target: CharacterBody2D # Navigation target

# All generic sounds for all enemies
@export_category("Enemy Sounds")
@export var sound_run: AudioStreamPlayer2D
@export var sound_hit: AudioStreamPlayer2D
@export var sound_attack: AudioStreamPlayer2D
@export var sound_death: AudioStreamPlayer2D


@export_category("Enemy Particles")
@export var hit_particle: PackedScene

# State changer handler
func set_state(new_state: States) -> void:
	#print("Changing state from ",States.find_key(current_state), " to ", States.find_key(new_state) )
	# if new state is same or is already dead, don't change
	if current_state == new_state or current_state == 4:
		return
	# if new state is death, change it and return
	if new_state == 4:
		current_state = new_state
		return
	# if state is hit, return (staggering) - the state resets when animation ends
	if current_state == 3 and not new_state == 0:
		return

	current_state = new_state
	

func set_target(target_position: Vector2) -> void:
	await get_tree().process_frame
	nav.target_position = target_position


func _navigate(delta: float) -> void:
	if raycast.is_colliding(): # Attack
		set_state(States.attack)
		return
	elif nav.is_navigation_finished(): # Not pursuing anything
		set_state(States.idle)
		return

	set_state(States.run)
	
	var direction = (nav.get_next_path_position() - global_position).normalized()
	translate(direction * speed * delta)
	move_and_slide()
	
	if entity_target == null:
		set_target(self.global_position)
		return
		
	set_target(entity_target.global_position)
	
	
func _check_surroundings() -> void:
	for object in los.get_overlapping_bodies():
		if object is Player:
				
			entity_target = object
			is_aggro = true
			is_patrolling = false
			
			if time_to_forget.is_stopped() == false:
				time_to_forget.stop()
	

func _update_health_bar() -> void:
	health_bar.max_value = max_health
	health_bar.value = health

# Spawns hit particle (based on enemy on exports) whever the enemy is hit
func _spawn_hit_particle(attacker_direction: Vector2) -> void:
	var in_hit_particle: GPUParticles2D = hit_particle.instantiate()
	
	# Connects the finished signal to a remove node func (to prevent bloat)
	in_hit_particle.finished.connect(GlobalHandler.global_remove.bind(in_hit_particle))
	
	# Adds particle to the scene and activates it
	in_hit_particle.global_position = global_position
	in_hit_particle.global_rotation = global_position.angle_to_point(attacker_direction)
	in_hit_particle.emitting = true
	add_sibling(in_hit_particle)

# Handles the entities' receiving damage
func got_hit(attacker: Player = null, incoming_damage: int = 1) -> void:
	# Not if already dead
	if current_state == States.death:
		return
		
	# Applies the damage and al GFX flavour
	health -= incoming_damage
	GlobalHandler.show_floating_damage(self, incoming_damage)
	_spawn_hit_particle(attacker.global_position)
	_update_health_bar()
	
	# Play hit sound
	GlobalHandler.rando_pitch_audio_play(sound_hit, 0.85, 1.15)
	
	# Set the entity to death if no more health
	if health <= 0:
		set_state(States.death)
		# Adds score to player if it was the one who hit the enemy
		# (damage could come from other sources)
		if attacker != null:
			attacker.add_score(score_reward)
		return
	
	# Reset animation if gets hit when it's already being hit
	if current_state == 3:
		_reset_animation()
		_animate()
	
	# if enemy still stands, set state to hit
	set_state(States.hit)

	
	# locates the attacker if not aggroed
	if is_aggro == false:
		entity_target = attacker
	
	
# Animates the enemy based on the current state
func _animate() -> void:
	# Do not change animation if entity is dying
	if sprite.animation == "death":
		return
		
	_flip_character(nav.target_position.x)
	sprite.play(States.find_key(current_state))


func _reset_animation() -> void:
	sprite.stop()


# Handles sprite directions
func _flip_character(axis: float) -> void:
	if axis < position.x:
		sprite.flip_h = true
		if is_flying == true:
			return
		raycast.scale.x = -1
	else:
		sprite.flip_h = false 
		if is_flying == true:
			return
		raycast.scale.x = 1


# Basic behaviour for entities (enemies)
func _ai_generic_behaviour(delta: float) -> void:
	
	# if a flying enemy is dead, drop them to the ground
	if is_flying == true and current_state == 4:
		var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
		velocity.y = move_toward(velocity.y, gravity, delta * gravity)
		move_and_slide()
		
	_animate()
	
	if current_state == 3 or current_state == 4:
		return

	_check_surroundings()
	if entity_target != null:
		set_target(entity_target.global_position)
		_navigate(delta)
	elif is_patrolling == true:
		pass
	else:
		set_target(self.global_position)
		_navigate(delta)
