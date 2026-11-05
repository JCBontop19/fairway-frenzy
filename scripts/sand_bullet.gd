extends Area2D

@export var speed := 400
var direction := Vector2.LEFT

func _physics_process(delta):
	position += direction * speed * delta

	if position.x < -200 or position.x > 3000 or position.y < -200 or position.y > 1500:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1)
		queue_free()
