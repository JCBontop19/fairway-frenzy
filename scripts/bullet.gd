extends Area2D

@export var speed := 1300
@export var rotation_speed := 1000.0
@export var damage: int = 1
@export var pierce: bool = false

@onready var anim := $AnimatedSprite2D

var direction := Vector2.RIGHT

func _ready():
	monitoring = true
	monitorable = true
	
	var frame_count = anim.sprite_frames.get_frame_count("colors")
	var random_frame = randi() % frame_count

	anim.play("colors")
	anim.frame = random_frame

func _physics_process(delta):
	position += direction * speed * delta
	rotation_degrees -= rotation_speed * delta
	if position.x > get_viewport_rect().size.x + 50:
		queue_free()

func _on_area_entered(area):
	_handle_hit(area)

func _on_body_entered(body):
	_handle_hit(body)

func _handle_hit(target):
	var enemy = null

	if target.is_in_group("enemy"):
		enemy = target
	elif target.get_parent() and target.get_parent().is_in_group("enemy"):
		enemy = target.get_parent()

	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		if not pierce:
			queue_free()
	else:
		queue_free()
