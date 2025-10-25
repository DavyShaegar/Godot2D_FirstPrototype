class_name Player
extends CharacterBody2D
## Player controlled character script

@export_category("Player Stats")
@export var health: int = 100
@export var max_health: int = health
@export var speed: int = 250
@export var melee_damage: int = 5
@export var acceleration: int = 200
@export var deceleration: int = 600
@export var jump_speed: int = -450
@export var throw_cooldown: float = 1.0
@export var throwing: bool = false
@export var score: int

@export_category("Player Nodes")
@export var sprite: AnimatedSprite2D
@export var areaof_melee_attack: Area2D
@export var player_panel: PanelContainer
@export var health_counter: ProgressBar
@export var death_screen: Control
@export var ranged_weapon_icon: TextureRect
@export var ranged_weapon_ammo: Label

@export_category("Player Audio")
@export var sword_swing: AudioStreamPlayer2D
@export var steps: AudioStreamPlayer2D
@export var dagger_sound: AudioStreamPlayer2D
@export var death: AudioStreamPlayer2D
@export var jumpsound: AudioStreamPlayer2D


@export_category("Throw Weapons")
@export var dagger: PackedScene
@export var dagger_count: int

var steps_audio_pool: Array[AudioStreamMP3] = [
		load("res://Sounds/sfx/footstep_1.mp3"),
		load("res://Sounds/sfx/footstep_2.mp3"),
]


enum States {idle, run, jump, landing, attack, death}

@export_category("Player States and Checks")
@export var current_state: States = States.idle
@export var attacking: bool = false


var falling_speed: float # For landing. If too high, play animation and such


## State changer handler
func set_state(new_state: States) -> void:
	#print(States.find_key(current_state))
	
	# if new state is same, don't change
	if current_state == new_state:
		return
	
	# if char is dead, return
	if current_state == 5:
		return
		
	# if new state is death, change it and return
	# player can die anytime, disregarding state changing logic
	if new_state == 5:
		current_state = new_state
		return
	
	# Change from attack state is handled via animation
	if attacking == true:
		return
	
	# If jumping or falling, don't change state
	if current_state == 2 and not is_on_floor():
		return
		
		
	current_state = new_state
	
	
## Animates the character based on the current state
func _animate() -> void:
	# Do not change animation if entity is dying
	if sprite.animation == "death":
		return
	# If player is falling, don't change animation
	elif sprite.animation == "falling" and not is_on_floor():
		return
		
	sprite.play(States.find_key(current_state))


# Handles sprite directions based on input
func _flip_character(axis: float) -> void:
	if axis < 0:
		sprite.flip_h = true
		areaof_melee_attack.position.x = -18
	else:
		sprite.flip_h = false 
		areaof_melee_attack.position.x = 18


# Adds score to the player
func add_score(score_to_add: int) -> void:
	score += score_to_add


# Sets the ranged weapon
func change_ranged_weapon(weapon: PackedScene) -> void:
	# Instatiate to acces vars
	var in_weapon := weapon.instantiate()

	# Sets vars
	dagger = weapon
	dagger_count = in_weapon.def_count
	ranged_weapon_icon.texture = in_weapon.sprite
	
	# Deletes instatiated weapon
	in_weapon.queue_free()
	
	
# Handles melee attack
func _attack() -> void:
	set_state(States.attack)
	attacking = true


# Handles getting hit by... anything
func got_hit(incoming_damage: int) -> void:
	# Set the entity to death if no more health
	if health <= 0:
		set_state(States.death)
		return
		
	health -= incoming_damage
	GlobalHandler.show_floating_damage(self, incoming_damage)


# Handles dagger throwing (to hit enemies above)
func _throw_dagger() -> void:
	# No daggers in inventory
	if dagger_count < 1:
		return
		
	throwing = true
	dagger_count -= 1
	update_ui()
	
	dagger_sound.play()
	var in_dagger := dagger.instantiate()
	in_dagger.set_dagger_owner(self)
	
	# This sets the dagger position to the player position + a little above him :)
	# this 'cause dagger is instantiated in a basic node with no position inheritance
	# so that the dagger won't follow the player after being thrown 
	in_dagger.position = global_position + Vector2(0, -25)
	in_dagger.throw(get_global_mouse_position())
	%Projectiles.add_child(in_dagger)
	
	# 1 second cooldown
	await get_tree().create_timer(throw_cooldown).timeout
	throwing = false


# Handles death
func _death() -> void:
	
	# Disables collision so that other entities can't interact with the dead body
	%CollisionShape2D.disabled = true
	
	# Hides HUD and shows death screen
	player_panel.visible = false
	%RangedWeaponContainer.visible = false
	death_screen.visible = true
	
	
## Handles movement
func _movement(delta: float) -> void:
	var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
	
	print(falling_speed)
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, gravity, delta * gravity)
		set_state(States.jump)
		falling_speed = velocity.y
	elif current_state == States.jump and falling_speed > 500.0 or current_state == States.landing:
		print("Current_State: ", States.find_key(current_state)," --- Velocity: ", falling_speed)
		set_state(States.landing)
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		move_and_slide()
		_animate()
		return
		
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		GlobalHandler.rando_pitch_audio_play(jumpsound, 0.85, 1.15)
		velocity.y = jump_speed
		
	_animate()
	
	var axis: float = Input.get_axis("left", "right")
	if axis:
		
		set_state(States.run)
		_flip_character(axis)
		
		# Reduce sliding when changing direction but keep acceleration time
		if velocity.x < 0 and axis > 0 or velocity.x > 0 and axis < 0:
			velocity.x = move_toward(velocity.x, 0, deceleration * delta)
			
		velocity.x = move_toward(velocity.x, speed * axis, acceleration * delta)
	else: # When no movement key is pressed
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		if velocity.x == 0: # When char is stopped
			set_state(States.idle)
		
	move_and_slide()
	

# Fire this function whenever ui needs to update its values
func update_ui() -> void:
	health_counter.value = health
	ranged_weapon_ammo.text = "x" + str(dagger_count)


func check_death() -> bool:
	if health <= 0:
		set_state(States.death)
		return true
	else:
		return false


func _ready() -> void:
	change_ranged_weapon(load("res://Scenes/Projectiles/dagger_projectile.tscn"))
	update_ui()


func _physics_process(delta: float) -> void:
	update_ui()
	if current_state == States.death:
		_animate()
		return
		
	check_death()
	_movement(delta)
	
	if Input.is_action_just_pressed("pause"):
		%Pause.visible = true
		get_tree().paused = true
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		_attack()

	if Input.is_action_just_pressed("throw") and throwing == false:
		_throw_dagger()


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		attacking = false
	elif sprite.animation == "death":
		_death()
	elif sprite.animation == "jump":
		sprite.play("falling")
	elif sprite.animation == "landing":
		set_state(States.idle)


# Sounds starts only when animation starts
func _on_animated_sprite_2d_animation_changed() -> void:
	if sprite.animation == "attack":
		GlobalHandler.rando_pitch_audio_play(sword_swing, 0.95, 1.05)
	elif sprite.animation == "death":
		death.play()


# Handles movement sounds syncronization
func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "run":
		if sprite.frame == 1 or sprite.frame == 5:
			steps.stream = steps_audio_pool.pick_random()
			steps.play()
			
	elif sprite.animation == "attack": # Melee attack
		if sprite.frame == 3:
			var overlapping_bodies: Array[Node2D] = areaof_melee_attack.get_overlapping_bodies()
			if overlapping_bodies == []:
				return
			
			# All enemies in range are affected
			for body in overlapping_bodies:
				body.got_hit(self, melee_damage)
			
