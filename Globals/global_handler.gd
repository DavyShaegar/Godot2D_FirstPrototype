extends Node
## Global Script
## This stores some basic global functions

# Floating damage when something is hit
# set color based on who's getting hit (player = red, enemy = white)
@onready var floating_damage: PackedScene = load("res://Scenes/ui/floatingdamage.tscn")

## Fades out the screen
func fade_in(canvas: CanvasModulate, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(canvas, "color", Color(1, 1, 1, 1), duration)


func fade_out(canvas: CanvasModulate, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(canvas, "color", Color(0, 0, 0, 1), duration)


func _floating_damage_effect(damage_node: Label) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(5.0, -10.0), 0.25).from_current()
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(-5.0, -20.0), 0.25)
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(5.0, -30.0), 0.25)
	tween.tween_property(damage_node, "global_position", damage_node.global_position + Vector2(5.0, -40.0), 0.4)
	tween.parallel().tween_property(damage_node, "modulate", Color(1, 1, 1, 0), 0.4)
	
	await tween.finished
	damage_node.queue_free()
	
	
func show_floating_damage(entity_hit: CharacterBody2D, damage: int) -> void:
	var in_floating_damage: Label = floating_damage.instantiate()
	
	if entity_hit is Player:
		in_floating_damage.add_theme_color_override("font_color", Color.RED)
	elif entity_hit is Enemy:
		in_floating_damage.add_theme_color_override("font_color", Color.GRAY)
		
	in_floating_damage.text = "- " + str(damage)
	in_floating_damage.global_position = entity_hit.global_position - Vector2(0, 50)
	add_child(in_floating_damage)
	_floating_damage_effect(in_floating_damage)
