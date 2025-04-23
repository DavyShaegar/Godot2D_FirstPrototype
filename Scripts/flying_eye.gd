extends CharacterBody2D

#Gets all the character's animations
@onready var animation = $AnimatedSprite2D
#Gets the player character
@onready var player

#Gets hitboxes
@onready var collision = $playerdectection/collision


enum states {idle, run, attack, death, hit}

@export var health : int = 2
@export var current_state = states.idle
var raycoll
@export var SPEED : float = Enemyvars.Eye_SPEED
@onready var wingflap = $wingflap
@onready var soundhit = $hit
@onready var sounddeath = $death
@onready var attack = $attack

func movement(delta):
	current_state = states.run
	global_position.x = move_toward(global_position[0], player.position[0], SPEED * delta)
	global_position.y = move_toward(global_position[1], player.position[1]-40, SPEED * delta)
	move_and_slide()
	
func damage():
	var hit = int(randf_range(3,5))
	player.health -= hit
	

	
func animating():
	# Flips the animation and the raycast based on the position of the player (The sprite faces the player)
	if current_state != states.death:
		if player.global_position < global_position: 
			animation.flip_h = true
		else:
			animation.flip_h = false
		
	if current_state == states.idle or current_state == states.run:
		animation.play("idle_move")
	elif current_state == states.attack:
		animation.play("attack")
	elif current_state == states.death:
		animation.play("death")
	elif current_state == states.hit:
		animation.play("hit")


func _physics_process(delta):
	SPEED = Enemyvars.Eye_SPEED
	player = get_tree().get_nodes_in_group("player")[0]
	
	if player.current_state == player.states.death:
		current_state = states.idle
		
	animating()
	
	if current_state == states.death:
		if global_position.y < -30:
			global_position.y += 150 * delta
		return
		
	if current_state == states.hit or current_state == states.attack: return

	if player.current_state != player.states.death:
		movement(delta)
	else:
		global_position.x = move_toward(global_position[0], global_position[0], SPEED * delta)
		current_state = states.idle

func _on_animated_sprite_2d_animation_finished():
	if current_state == states.run or current_state == states.idle:
		wingflap.play()
	elif current_state == states.attack:
		attack.play()
		get_node("/root/MainGame").damage()
	elif current_state == states.hit:
		current_state = states.run
	elif current_state == states.death:
		queue_free()

func _on_animated_sprite_2d_animation_changed():
	if current_state == states.hit:
		soundhit.play()
	elif current_state == states.death:
		sounddeath.play()

func _on_playerdectection_body_entered(body):
	if current_state == states.death: return
	if body.name == "Player":
		current_state = states.attack
		
func _on_playerdectection_body_exited(body):
	if current_state == states.death: return
	if body.name == "Player":
		current_state = states.run
