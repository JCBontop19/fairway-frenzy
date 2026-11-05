extends CharacterBody2D

@export var move_speed := 140
@export var fire_rate := 2.5
@export var max_health := 7
@export var sand_bullet_scene: PackedScene
@export var path_type := "straight"
@onready var health_bar: Node2D = $HealthBar

var health := max_health
var arrived := false
var direction := Vector2.LEFT

func _ready():
	$FireTimer.wait_time = fire_rate
	$FireTimer.stop()
	if health_bar:
		health_bar.max_value = max_health
		health_bar.current_value = health

func _physics_process(delta):
	# Move onto screen first
	if not arrived:
		position.x += direction.x * move_speed * delta
		
		if position.x < get_viewport().size.x - 350:
			arrived = true
			$FireTimer.start()
	else:
		# You can add light drifting here if you want:
		# position.y += sin(Time.get_ticks_msec() * 0.001) * 1.5
		pass

func _on_fire_timer_timeout():
	if not $ScreenNotifier.is_on_screen():
		return

	_fire_burst()

func _fire_burst():
	if not $ScreenNotifier.is_on_screen():
		return

	# CENTER BULLET (straight left)
	_spawn_bullet(Vector2.LEFT)

	# UPPER BULLET (up-left)
	_spawn_bullet(Vector2(-1, -0.4).normalized())

	# LOWER BULLET (down-left)
	_spawn_bullet(Vector2(-1, 0.4).normalized())

func _spawn_bullet(dir: Vector2):
	if sand_bullet_scene == null:
		push_error("❌ Sand bullet scene not assigned!")
		return

	var bullet = sand_bullet_scene.instantiate()
	bullet.direction = dir
	bullet.global_position = global_position
	get_tree().current_scene.add_child(bullet)
	$shootSound.play()

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
			gm.enemy_defeated(400)

		queue_free()

func _flash():
	modulate = Color(0.60, 0.0, 0.15, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

func _on_hitbox_body_entered(body):
	if body.is_in_group("player_bullet"):
		if has_method("take_damage"):
			take_damage(1)
