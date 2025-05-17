class_name Dagger
extends Area2D
## Dagger thrown upwards by the player
## Stats can be changed with global attacks_handler

@export_category("Projectile Stats")
@export var speed: int = 450
@export var damage: int = 2

@onready var target: Vector2


func throw(direction: Vector2) -> void:
	look_at(direction)
	target = global_position.direction_to(direction)
	

func _physics_process(delta: float) -> void:
	translate(target * speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.got_hit(damage)
		queue_free()
	else:
		queue_free()

# Deletes the projectile after a while if it hasn't hit anything
func _on_time_to_live_timeout() -> void:
	queue_free()
