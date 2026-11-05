extends CharacterBody2D

@export var speed := 160
@export var bullet_scene: PackedScene
@export var fire_rate := 2.0
@export var max_health := 3

@onready var health_bar: Node2D = $HealthBar
@onready var shoot_timer: Timer = $ShootTimer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $ScreenNotifier

var health := max_health
var path_type := "straight"
var direction := Vector2.LEFT
var on_screen := false
var time := 0.0

func _ready() -> void:
	health = max_health

	shoot_timer.stop()

	if health_bar:
		health_bar.max_value = max_health
		health_bar.current_value = health

func _physics_process(delta: float) -> void:
	time += delta

	match path_type:
		"straight":
			position.x += direction.x * speed * delta

		"ascending":
			position.x += direction.x * speed * delta
			position.y += -100 * delta

		"descending":
			position.x += direction.x * speed * delta
			position.y += 100 * delta

		"zigzag":
			position.x += direction.x * speed * delta
			position.y += sin(time * 6.0) * 90

	var w = get_viewport().size.x
	var h = get_viewport().size.y

	if not on_screen and position.x < w:
		on_screen = true
		shoot_timer.start(fire_rate)

	if position.x < -50:
		position.x = w + 50

	if position.y < -50:
		position.y = h + 50
	elif position.y > h + 50:
		position.y = -50

func take_damage(amount := 1):
	if not $ScreenNotifier.is_on_screen():
		return

	health -= amount
	_flash()
	$hitSound.play()

	var gm = get_tree().current_scene.get_node("GameManager")
	if gm and gm.has_method("add_ult_charge"):
		gm.add_ult_charge(amount)

	if health_bar:
		health_bar.current_value = health

	if health <= 0:
		$deathSound.play()

		if gm:
			if gm.has_method("maybe_spawn_pickup"):
				gm.maybe_spawn_pickup(global_position)
			gm.enemy_defeated(100)

		queue_free()

func _flash() -> void:
	modulate = Color(0.60, 0.0, 0.15, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func _on_shoot_timer_timeout() -> void:
	if bullet_scene:
		var b = bullet_scene.instantiate()
		b.global_position = global_position + Vector2(-20, 0)
		$shootSound.play()
		get_tree().current_scene.add_child(b)

func _on_hitbox_body_entered(body):
	if body.is_in_group("player_bullet"):
		if has_method("take_damage"):
			take_damage(1)
