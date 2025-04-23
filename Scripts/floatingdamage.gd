extends Node

# Called when the node enters the scene tree for the first time.
func showdamage(hit):
	var damage_popup = get_node("Label")
	damage_popup.text = "-"+str(hit)
