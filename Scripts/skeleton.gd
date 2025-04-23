extends CharacterBody2D
@onready var animation = $AnimatedSprite2D
@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var RayCast = $RayCast2D
@onready var skelhit = $SkellingtonPunch
@onready var skeldeath = $skellington_death
@onready var skellington_hugedeath = $skellington_hugedeath
@export var health : int = 3
@export var current_state = states.idle
@onready var attackcheck : bool = true 
@export var SPEED : float = Enemyvars.Skel_SPEED
var raycoll
enum states {idle, run, attack, death, hit}
#region Functions
### FUNCTIONS ###
func movement(delta):
	# Moves the character towards the player and plays the animation
	global_position.x = move_toward(global_position[0], player.position[0] ,SPEED * delta)
	current_state = states.run
	move_and_slide()
	
func attack(delta):
	raycoll = RayCast.get_collider()
	#if raycoll == null: return
	if raycoll.name == "Player":
		current_state = states.attack
	else:
		movement(delta)
	
func animating():
	# Flips the animation and the raycast based on the position of the player (The sprite faces the player)
	if global_position > player.global_position: 
		animation.flip_h = true
		RayCast.scale.x = -1 
	else:
		RayCast.scale.x = 1 
		animation.flip_h = false
		
	if current_state == states.idle:
		animation.play("idle")
	elif current_state == states.run:
		animation.play("walk")
	elif current_state == states.attack:
		animation.play("attack")
	elif current_state == states.death:
		animation.play("death")
	elif current_state == states.hit:
		animation.play("hit")

#endregion

func _process(delta):

	SPEED = Enemyvars.Skel_SPEED
	
	animating()
	if current_state == states.death || current_state == states.hit: return
	
	player = get_tree().get_nodes_in_group("player")[0]
	if player.current_state != player.states.death:
		if RayCast.is_colliding():	
			attack(delta)
		else:
			movement(delta)
	else:
		global_position.x = move_toward(global_position[0], global_position[0], SPEED * delta)
		current_state = states.idle


func _on_animated_sprite_2d_animation_finished():
	if current_state == states.attack:
		get_node("/root/MainGame").damage()
		skelhit.play()
	elif current_state == states.hit:
		current_state = states.run
	elif current_state == states.death:
		self.queue_free()
	

func _on_animated_sprite_2d_animation_changed():
	if current_state == states.death:
		skellington_hugedeath.play()
