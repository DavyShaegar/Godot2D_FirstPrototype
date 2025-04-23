extends Node2D

# Gets the spawn points
@onready var enemypos_right = $spawnpointright
@onready var enemypos_left = $spawnpointleft
@onready var enemypos_upRT= $spawnpointupright
@onready var enemypos_upLF = $spawnpointupleft
# Gets the player
@onready var player = $Player
# Initiates player's score
@onready var score = 0
@onready var prevscore = 0
@onready var scoremultiplier : float = 1.0
# Gets the ui
@onready var ui = $UI
@onready var health_counter = $UI/HealthCounter
@onready var score_counter = $UI/ScoreCounter
# Health var for counter
@onready var addhealth = 100
# Packed scenes
@export var skellington: PackedScene
@export var flyingeye: PackedScene
@export var dagger: PackedScene
@export var deathscreen: PackedScene
@export var damagepopup: PackedScene
# Initializes the enemy count
var skeletoncount = 0
var eyecount = 0

### CODE ###
# Keeps track of the health counter
func healthCount():
	
	var currenthealth = player.health

	# Updates health counter
	if currenthealth != addhealth:
		health_counter.clear()
		if player.health < 0:
			addhealth = 0
		else:
			addhealth = player.health
		health_counter.add_text("Health: " + str(addhealth))
# Keeps track of the score counter
func ScoreCount():
	if score != prevscore:
		score_counter.clear()
		score_counter.add_text("Score: "+ str(score))
		prevscore = score
# Real time processes
func _process(_delta):
	# Handles health UI counter
	healthCount()
	# Handles the score counter
	ScoreCount()
# Spawn an enemy every 4 seconds
func _on_skel_spawn_timer_timeout():
	
	# Creates a skeleton enemy instance
	var skeleton = skellington.instantiate()
	# Createsa a random number
	var random = int(randf_range(0,2))
	# Only 5 skeletons at a time
	if skeletoncount < 5:
		#print(random)
		# Spawns a skeleton on a random spawn point
		if random == 1:
			skeleton.set_position(enemypos_right.position)
			add_child(skeleton)
		else:
			skeleton.set_position(enemypos_left.position)
			add_child(skeleton)
		
		# Keeps count of the skeletons in the game
		skeletoncount+=1

# 8 Seconds
func _on_eye_spawn_timer_timeout():
	var eye = flyingeye.instantiate()
	var random = int(randf_range(0,2))
	
	if eyecount < 2:
		if random == 1:
			eye.set_position(enemypos_upRT.position)
			add_child(eye)
		else:
			eye.set_position(enemypos_upLF.position)
			add_child(eye)
		
		eyecount+=1

# Handles the damage dealt to the player and the graphical popup
func damage():
	var hit = int(randf_range(1,4))
	player.health -= hit
	
	# Adds the scene with said damage
	var floatingdamage = damagepopup.instantiate()
	floatingdamage.position = player.position + Vector2(0, -30)
	add_child(floatingdamage)
	floatingdamage.showdamage(hit)

# Gets the enemy hit by the player and handles its behaviour
func enemydeath(raycoll):
	if raycoll.health < 1:
		raycoll.current_state = raycoll.states.death
		raycoll.get_node("collision").queue_free()
		
		# Kills the enemy and gives the player score
		# Gives score to the player
		if raycoll.is_in_group("skeletons"):
			skeletoncount -= 1
			score += int(round(Enemyvars.Skel_Score * scoremultiplier))
		else:
			eyecount -= 1
			score += int(round(Enemyvars.Eye_Score * scoremultiplier))
			
	else:
		raycoll.current_state = raycoll.states.hit
		raycoll.health -= 1

# Handles the hit against the skeletons
func _on_player_hit_enemy(raycoll):
	if raycoll.name == "skeleton" or raycoll.name == "flying_eye":
		if raycoll.health != 0 and raycoll.name == "skeleton":
			raycoll.skeldeath.play()
		enemydeath(raycoll)

# Increase enemies speed after a while
func _on_speed_timer_timeout():
	scoremultiplier += 0.1
	print("Speed increase")
	if Enemyvars.Skel_SPEED <= 30:
		Enemyvars.Skel_SPEED += 0.15
	if Enemyvars.Eye_SPEED <= 30:
		Enemyvars.Eye_SPEED += 0.15

# Plays the music
func _on_ready():
	if Options.music != false:
		Ambience.get_node("music").play()

# Handles the throwing dagger feature (hits above player)
func _on_player_throw_dagger():
	if player.current_state != player.states.attack:
		var dagg = dagger.instantiate()
		#dagg.set_position(global_position)
		dagg.global_position = player.global_position
		dagg.global_position.y = player.global_position.y - 40.0
		add_child(dagg)
		dagg.get_node("Area2D/daggerthrow").play()
# Handles the death screen after the player's death
func _on_player_deathscreen():
	var youdied = deathscreen.instantiate()
	youdied.set_position(get_node("UI/deathscreenpos").global_position)
	get_node("UI").add_child(youdied)
