class_name Enemy
extends CharacterBody2D

## This is the base enemy class
## This stores all the default attributes and methods
## Some will be overridden

@export_category("Enemy Stats")
@export var health: int
@export var damage: int
@export var speed: int


@export_category("Enemy Nodes")
@export var sprite: AnimatedSprite2D # Animation
@export var raycast: RayCast2D # Checks collision with player and level geometry
@export var nav: NavigationAgent2D # Navigation for enemy movement (especially flying ones)
@export var collision: CollisionShape2D # Remove this when death animation plays so that the body won't be an obstable
@export var los: Area2D # Line of sight. Handles entity perception
@export var time_to_forget: Timer # Time for the entity to reset aggro if target is outside reach


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
	if nav.is_navigation_finished():
		set_state(States.idle)
		return
	elif raycast.is_colliding():
		set_state(States.attack)
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
	
	
func got_hit(incoming_damage: int) -> void:
	# Set the entity to death if no more health
	if health <= 0:
		set_state(States.death)
		return
	
	_play_randomise_pitch(%skel_hurt)
	
	# Reset animation if gets hit when it's already being hit
	if current_state == 3:
		_reset_animation()
		_animate()
		
	set_state(States.hit)
	health -= incoming_damage
	## add floating damage here
	
	
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
		raycast.scale.x = -1
	else:
		sprite.flip_h = false 
		raycast.scale.x = 1


func _play_randomise_pitch(audio_node: AudioStreamPlayer2D) -> void:
	audio_node.pitch_scale = randf_range(0.85, 1.15)
	audio_node.play()


# Basic behaviour for entities (enemies)
func _ai_generic_behaviour(delta: float) -> void:
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
