extends RichTextLabel

# Get the player
@onready var player = $"../Player"

@onready var addhealth = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var currenthealth = player.health
	
	# Updates health counter
	if currenthealth != addhealth:
		clear()
		addhealth = player.health
		#print("currenthealth: "+str(currenthealth)+" addhealth: "+str(addhealth))
		add_text("Salute: " + str(addhealth))
