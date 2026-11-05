extends CharacterBody2D

@export var max_health := 200
@onready var health_bar: Node2D = $HealthBar
@onready var gfx := $Sprite2D
var health := max_health

var phase := 0
var can_attack := false

@export var move_speed := 120

@export var ball_scene: PackedScene
@export var slash_duration := 1.0
@export var pin_speed := 900
@export var path_type = "boss"

var shake_time := 0.8
var shake_strength := 7.0
var original_gfx_pos: Vector2

func _ready():
	phase = 0
	can_attack = false

	$AttackTimer.stop()
	$PhaseTimer.stop()

	position.x = get_viewport().size.x + 300
	original_gfx_pos = gfx.position
	_enter_screen()
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.current_value = health

func _enter_screen():
	var target_x = get_viewport().size.x - 500
	var tween = create_tween()
	tween.tween_property(self, "position:x", target_x, 2.8)
	tween.tween_callback(Callable(self, "_start_phase_loop"))

func _start_phase_loop():
	can_attack = true
	phase = 1
	$PhaseTimer.start(1.0)

func _on_phase_timer_timeout():
	if not can_attack:
		return

	match phase:
		1: _phase_ball_spread()
		2: _phase_flag_slash()
		3: _phase_pin_attack()
		4: _phase_ball_rain()
		5: _phase_enrage()

func _phase_ball_spread():
	for i in range(3):
		_shoot_spread()
		await get_tree().create_timer(1.0).timeout
	_next_phase()

func _shoot_spread():
	var angles = [-25, -12, 0, 12, 25]

	for deg in angles:
		var b = ball_scene.instantiate()
		b.global_position = $BallSpawnPoint.global_position
		b.direction = Vector2.LEFT.rotated(deg_to_rad(deg))
		get_tree().current_scene.add_child(b)

func _phase_flag_slash():
	$SlashArea.visible = true
	$SlashArea/SlashCollision.disabled = false

	await get_tree().create_timer(slash_duration).timeout

	$SlashArea.visible = false
	$SlashArea/SlashCollision.disabled = true
	_next_phase()

func _shake_warning() -> void:
	var t := shake_time
	while t > 0.0:
		t -= get_process_delta_time()
		gfx.position = original_gfx_pos + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		await get_tree().process_frame
	gfx.position = original_gfx_pos

func _phase_pin_attack():
	await _shake_warning()

	var start_pos = position
	var off_left = Vector2(-300, position.y)

	var tween = create_tween()
	tween.tween_property(self, "position", off_left, 0.8)
	tween.tween_callback(func():
		position = Vector2(get_viewport().size.x + 250, start_pos.y)
	)
	tween.tween_property(self, "position", start_pos, 0.8)

	await tween.finished
	_next_phase()

func _phase_ball_rain():
	var width = get_viewport().size.x

	for i in range(15):
		var b = ball_scene.instantiate()
		b.global_position = Vector2(randf() * width, -15)
		b.direction = Vector2.DOWN
		get_tree().current_scene.add_child(b)

	await get_tree().create_timer(1.5).timeout
	_next_phase()

func _phase_enrage():
	for i in range(6):
		_shoot_spread()
		await get_tree().create_timer(0.6).timeout
	
	await get_tree().create_timer(0.5).timeout
	_phase_flag_slash()
	_phase_pin_attack()

	$PhaseTimer.start(3.0)

func _next_phase():
	phase += 1
	if phase > 5:
		phase = 1

	$PhaseTimer.start(3.0)

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

func _die():
	can_attack = false
	$PhaseTimer.stop()
	$AttackTimer.stop()

	var gm = get_tree().current_scene.get_node_or_null("GameManager")
	if gm:
		$deathSound.play()
		gm.enemy_defeated(9999)

	queue_free()

func _flash():
	modulate = Color(0.60, 0.0, 0.15, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

func _on_slash_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(2)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_bullet"):
		if has_method("take_damage"):
			take_damage(1)
