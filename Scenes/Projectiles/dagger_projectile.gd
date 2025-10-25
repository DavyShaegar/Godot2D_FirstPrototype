class_name Dagger
extends Area2D
## Dagger thrown by the player

@export_category("Projectile Stats")
@export var speed: int = 450
@export var damage: int = 2
@export var def_count: int = 20
@export var sprite: CompressedTexture2D

@onready var target: Vector2
@onready var dagger_owner: Node

# Sets the dagger's owner
# Call this when spawning dagger to attribute damage correctly
func set_dagger_owner(spawner: Node) -> void:
	dagger_owner = spawner


# Plays hit sound (Creates a copy to instantiate outside, as dagger will be deleted)
func _play_hit_sound() -> void:
	var new_sound: AudioStreamPlayer2D = %HitSound.duplicate()
	new_sound.global_position = global_position
	get_tree().current_scene.add_child(new_sound)
	new_sound.play()


func throw(direction: Vector2) -> void:
	look_at(direction)
	target = global_position.direction_to(direction)
	

func _physics_process(delta: float) -> void:
	translate(target * speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		_play_hit_sound()
		body.got_hit(dagger_owner, damage)
		queue_free()
	else:
		queue_free()


# Deletes the projectile after a while if it hasn't hit anything
func _on_time_to_live_timeout() -> void:
	queue_free()
