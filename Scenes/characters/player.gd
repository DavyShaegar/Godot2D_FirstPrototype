class_name Player
extends CharacterBody2D
## Player controlled character script

@export_category("Player Stats")
@export var health: int = 100
@export var speed: int = 200
@export var jump_speed: int = -350
@export var throw_cooldown: float = 1.0
@export var throwing: bool = false

@export_category("Player Nodes")
@export var sprite: AnimatedSprite2D
@export var cast: RayCast2D
@export var health_counter: RichTextLabel
@export var score_counter: RichTextLabel

@export_category("Player Audio")
@export var sword_swing: AudioStreamPlayer2D
@export var steps: AudioStreamPlayer2D
@export var dagger_sound: AudioStreamPlayer2D
@export var death: AudioStreamPlayer2D


@export_category("Instances")
#@export var death_screen: PackedScene = load("res://Scenes/ui/deathscreen.tscn")
@export var dagger: PackedScene = load("res://Scenes/Projectiles/dagger_projectile.tscn")


var steps_audio_pool: Array[AudioStreamMP3] = [
		load("res://Sounds/sfx/footstep_1.mp3"),
		load("res://Sounds/sfx/footstep_2.mp3"),
]


enum States {idle, run, jump, attack, death}

@export_category("Player States and Checks")
@export var current_state: States = States.idle
@export var attacking: bool = false


## State changer handler
func set_state(new_state: States) -> void:
	#print(States.find_key(current_state))
	
	# if new state is same, don't change
	if current_state == new_state:
		return
	
	# if new state is death, change it and return
	# player can die anytime, disregarding state changing logic
	if new_state == 4:
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
	sprite.play(States.find_key(current_state))


# Handles sprite directions based on input
func _flip_character(axis: float) -> void:
	if axis < 0:
		sprite.flip_h = true
		cast.scale.x = -1
	else:
		sprite.flip_h = false 
		cast.scale.x = 1


# Handles melee attack
func _attack() -> void:
	set_state(States.attack)
	attacking = true


# Handles dagger throwing (to hit enemies above)
func _throw_dagger() -> void:
	throwing = true
	
	dagger_sound.play()
	var in_dagger := dagger.instantiate()
	
	# This sets the dagger position to the player position + a little above him :)
	# this 'cause dagger is instantiated in a basic node with no position inheritance
	# so that the dagger won't follow the player after being thrown 
	in_dagger.position = global_position + Vector2(0, -25)
	
	%Projectiles.add_child(in_dagger)
	
	# 1 second cooldown
	await get_tree().create_timer(throw_cooldown).timeout
	throwing = false


# Handles death
func _death() -> void:
	get_tree().quit(0)
	
	
## Handles movement
func _movement(delta: float) -> void:

	var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, gravity, delta * gravity)
		set_state(States.jump)
		
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		
	_animate()
	
	var axis: float = Input.get_axis("left", "right")
	if axis:
		
		# remove sliding when changing direction
		if velocity.x < 0 and axis > 0:
			print("change to the right")
		elif velocity.x > 0 and axis < 0:
			print("Change to the left")
			
		set_state(States.run)
		_flip_character(axis)
		velocity.x = move_toward(velocity.x, speed * axis, speed * delta)
	else: # When no movement key is pressed
		velocity.x = move_toward(velocity.x, 0, speed * delta * 10)
		if velocity.x == 0: # When char is stopped
			set_state(States.idle)
		
	move_and_slide()
	

# Fire this function whenever ui needs to update its values
func update_ui() -> void:
	health_counter.text = "Health: " + str(health)
	score_counter.text = "Score: 0"


func _ready() -> void:
	update_ui()


func _physics_process(delta: float) -> void:
	## REMOVE
	if health == 0:
		set_state(States.death)
		
	_movement(delta)
	
	if Input.is_action_just_pressed("attack") and is_on_floor():
		_attack()

	if Input.is_action_just_pressed("throw") and throwing == false:
		_throw_dagger()

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		attacking = false
	elif sprite.animation == "death":
		_death()


# Sounds starts only when animation starts
func _on_animated_sprite_2d_animation_changed() -> void:
	if sprite.animation == "attack":
		sword_swing.play()
	elif sprite.animation == "death":
		death.play()


# Handles movement sounds syncronization
func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.animation == "run":
		if sprite.frame == 1 or sprite.frame == 5:
			steps.stream = steps_audio_pool.pick_random()
			steps.play()
