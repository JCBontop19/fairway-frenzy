extends Area2D

@export var speed := 400
@export var rotation_speed := 1000.0
var direction := Vector2.LEFT

func _process(delta):
	global_position += direction * speed * delta
	rotation_degrees += rotation_speed * delta
	if global_position.x < -500 or global_position.x > 5000:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1)
		queue_free()
