extends Control

@onready var parallax_layer_1: ParallaxLayer = $Decoration/Parallax2D/ParallaxLayer
@onready var parallax_layer_2: ParallaxLayer = $Decoration/Parallax2D/ParallaxLayer2
@onready var parallax_layer_3: ParallaxLayer = $Decoration/Parallax2D/ParallaxLayer3
@onready var charmenu: AnimatedSprite2D = %charmenu
@onready var char_marker: Marker2D = %CharMarker
@onready var char_exit_marker: Marker2D = %CharExitMarker
@onready var optionsmenu: Control = %optionsmenu
@onready var menu_container: VBoxContainer = %MenuContainer

# This checks if menu is doing something (prevents overlap)
@onready var menu_busy: bool = false

# Audio
@onready var menu_click: AudioStreamPlayer2D = %MenuClick


func _move_char_to_position(character: AnimatedSprite2D, new_position: Vector2, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(character, "position", new_position, duration).from_current()


# Fades in the screen and moves the character forward
func _ready() -> void:
	GlobalHandler.fade_in(%Screen, 0.5)
	GlobalHandler.fade_in(%ParallaxScreen, 0.5)
	_move_char_to_position(charmenu, char_marker.position, 1.5)


func _physics_process(_delta: float) -> void:
	parallax_layer_1.motion_offset += Vector2(-0.01, 0)
	parallax_layer_2.motion_offset += Vector2(-0.1, 0)
	parallax_layer_3.motion_offset += Vector2(-0.2, 0)
	

# Moves the character to the left of the screen and fades to black
# Then it starts the game
func _on_start_pressed() -> void:
	if menu_busy == true:
		return
		
	menu_busy = true
	menu_click.play()
	
	_move_char_to_position(charmenu, char_exit_marker.position, 2.5)
	GlobalHandler.fade_out(%Screen, 1.0)
	GlobalHandler.fade_out(%ParallaxScreen, 1.0)
	await get_tree().create_timer(1.2).timeout
	
	get_tree().change_scene_to_file("res://Scenes/Levels/Level01.tscn")


func _on_options_pressed() -> void:
	if menu_busy == true:
		return
		
	menu_busy = true
	menu_click.play()
	
	# Shows the options menu
	optionsmenu.visible = true
	menu_container.visible = false
	
	# Resets the "business" of the menu
	# menu can be clicked again when back from options menu
	menu_busy = false
	
func _on_exit_pressed() -> void:
	if menu_busy == true:
		return
	
	menu_busy = true
	menu_click.play()
	
	GlobalHandler.fade_out(%Screen, 0.5)
	GlobalHandler.fade_out(%ParallaxScreen, 0.5)
	await get_tree().create_timer(0.7).timeout
	get_tree().quit(0)

# Options Menu back button
func _on_back_pressed() -> void:
	menu_click.play()
	
	optionsmenu.visible = false
	menu_container.visible = true
