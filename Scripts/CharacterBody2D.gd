extends CharacterBody2D

# General character speeds
const SPEED = 175.0
const JUMP_VELOCITY = -300.0
# Character Health, if 0 - game over
@export var health = 20
# Set states of the player which will be used to determine what animation to execute
enum states {idle, run, jump, attack, death}
@export var current_state = states.idle
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Gets the animations
@onready var pcanimation = $AnimatedSprite2D
# Gets the raycast that will be used for attacks
@onready var RayCast = $RayCast2D
# Gets the main scene (for accessing and changing enemy count)
@onready var game = $".."
# Sounds
@onready var deathsound = $deathsound
@onready var swingsound = $swing
@onready var foot_1 = $footstep_1
@onready var foot_2 = $footstep_2
# Custom Signals
signal hit_enemy
signal throw_dagger
signal deathscreen

# Dagger throw cooldown
@onready var cooldown = $cooldown
@onready var can_throw : bool = true

@onready var noinput : bool = false
@warning_ignore("shadowed_variable")

# When health is 0
func check_death(health):
	if health <= 0:	
		current_state = states.death
# Handles animations for all the player states
func animating():
	if current_state == states.death:
		pcanimation.play("death")
	elif current_state == states.jump or not is_on_floor():
		pcanimation.play("jump")
	elif current_state == states.idle:
		pcanimation.play("idle")
	elif current_state == states.run:
		pcanimation.play("run")
	elif current_state == states.attack:
		pcanimation.play("attack")
# When the attack button is pressed
func attack():
	var raycoll = RayCast.get_collider()
	# Play attack sound
	swingsound.play()
	
	# If target is valid
	if RayCast.is_colliding():
		# and if target is not already hit/dead
		if raycoll.current_state == raycoll.states.death || raycoll.current_state == raycoll.states.hit: return
		
		# Send the signal
		hit_enemy.emit(raycoll)
		#current_state = states.idle
# Handles the character's movement
func movement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		
		# Movement Speed
		velocity.x = direction * SPEED
		
		# Sets the state to run
		current_state = states.run
		
		# Checks whether to flip the animation (right, left movement)
		if velocity.x < 0:
			pcanimation.flip_h = true
			RayCast.scale.x = -1
		else:
			pcanimation.flip_h = false
			RayCast.scale.x = 1
			
	# Cancels momentum if in the air
	elif not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

# Handles gravity
func gravity_falling(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func _physics_process(delta):
	if noinput == true: return
	# Stops the cooldown if not necessary
	if can_throw == true: cooldown.stop()
	
	if Input.is_action_just_pressed("exit"):
		Ambience.get_node("music").stop()
		get_tree().change_scene_to_file("res://menu.tscn")
	# Animates the character
	animating()
	# Check if player is dead
	check_death(health)
	# Adds the gravity.
	gravity_falling(delta)
	# Don't accept inputs if char dead
	if current_state == states.death or pcanimation.animation == "attack": return
	# Idles the character if nothing is pressed
	
	if Input.is_anything_pressed() == false && current_state != states.attack:
		current_state = states.idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
	# Handles movement
	movement()
	# Handles the attack of the PC
	if Input.is_action_just_pressed("attack") and is_on_floor():
		current_state = states.attack
		Console.print_to_console("Attack")
	# Handles dagger throw
	if Input.is_action_just_pressed("throw") and can_throw == true:
		Console.print_to_console("Throw")
		can_throw = false
		cooldown.start()
		emit_signal("throw_dagger")
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Sets the state to jump
		current_state = states.jump

# Hadles events based on the character's animation ending
func _on_animated_sprite_2d_animation_finished():
	# character dead -> Game Over
	if current_state == states.death: 
		noinput = true
		pcanimation.pause()
		Ambience.get_node("music").stop()
		Ambience.get_node("gameover").play()
		emit_signal("deathscreen")
	# If attack animation ends, start the attack function
	elif current_state == states.attack:
		attack()
		current_state = states.idle

func _on_animated_sprite_2d_frame_changed():
	# Handles footsteps sounds
	# Only 2 times per animation and only when running on the ground
	if current_state == states.run and is_on_floor():
		if pcanimation.frame == 1 or pcanimation.frame == 5:
			var random = int(randf_range(0,1))
			if random == 1: foot_1.play()
			else: foot_2.play()
	# Plays death sound after death state and animation starting
	if pcanimation.frame == 1 and current_state == states.death: deathsound.play()


func _on_cooldown_timeout(): can_throw = true
