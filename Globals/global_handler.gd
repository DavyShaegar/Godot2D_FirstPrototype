extends Node
## Global Script
## This stores some basic global functions

## Fades out the screen
func fade_in(canvas: CanvasModulate, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(canvas, "color", Color(1, 1, 1, 1), duration)


func fade_out(canvas: CanvasModulate, duration: float) -> void:
	var tween := create_tween()
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(canvas, "color", Color(0, 0, 0, 1), duration)
