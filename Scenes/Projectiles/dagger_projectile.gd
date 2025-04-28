class_name Dagger
extends Area2D
## Dagger thrown upwards by the player
## Stats can be changed with global attacks_handler

@export_category("Projectile Stats")
@export var speed: int = 200
@export var damage: int = 10

func _physics_process(delta: float) -> void:
	position.y = move_toward(position.y, position.y + 1, - speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.got_hit(damage)
