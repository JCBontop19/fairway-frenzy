extends CharacterBody2D

@export var move_speed: float = 160.0
@export var fire_interval: float = 5.0
@export var laser_duration: float = 2.5
@export var max_health: int = 5
@export var warning_time: float = 1.0

@onready var health_bar: Node2D = $HealthBar
@onready var fire_timer: Timer = $FireTimer
@onready var laser_root: Node2D = $LaserRoot
@onready var laser_area: Area2D = $LaserRoot/LaserArea
@onready var laser_beam: ColorRect = $LaserRoot/LaserArea/LaserBeam
@onready var laser_collision: CollisionShape2D = $LaserRoot/LaserArea/LaserCollision
@onready var laser_timer: Timer = $LaserRoot/LaserArea/LaserTimer
@onready var screen_notifier: VisibleOnScreenNotifier2D = $ScreenNotifier
@onready var gfx := $Sprite2D

var health: int
var arrived := false
var direction := Vector2.LEFT
var path_type := "water_laser"
var shake_strength := 6.0
var original_gfx_pos: Vector2

func _ready() -> void:
	health = max_health
	original_gfx_pos = gfx.position
	fire_timer.wait_time = fire_interval
	fire_timer.stop()
	laser_root.visible = false
	laser_collision.disabled = true
	if health_bar:
		health_bar.max_value = max_health
		health_bar.current_value = health

func _physics_process(delta: float) -> void:
	if not arrived:
		position.x += direction.x * move_speed * delta
		if position.x < get_viewport().size.x - 300.0:
			arrived = true
			fire_timer.start()

func _shake_warning() -> void:
	var t := warning_time
	while t > 0.0:
		t -= get_process_delta_time()
		gfx.position = original_gfx_pos + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		await get_tree().process_frame
	gfx.position = original_gfx_pos

func _fire_laser() -> void:
	laser_root.visible = true
	var width: float = get_viewport().size.x + 200.0
	laser_beam.size.x = width
	laser_beam.position.x = -width
	laser_collision.shape.size.x = width
	laser_collision.position.x = -width * 0.5
	laser_collision.disabled = false
	laser_beam.modulate = Color(0.4, 0.85, 1.0, 1.0)
	laser_timer.start()
	$shootSound.play()

func _stop_laser() -> void:
	laser_root.visible = false
	laser_collision.disabled = true
	laser_timer.stop()

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
			gm.enemy_defeated(250)

		queue_free()

func _flash() -> void:
	modulate = Color(0.60, 0.0, 0.15, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func _on_fire_timer_timeout() -> void:
	await _shake_warning()
	_fire_laser()
	await get_tree().create_timer(laser_duration).timeout
	_stop_laser()

func _on_laser_timer_timeout() -> void:
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = laser_collision.shape
	query.transform = laser_collision.global_transform
	query.collide_with_bodies = true
	var results: Array = space_state.intersect_shape(query)
	for result in results:
		var body: Object = result.collider
		if body.is_in_group("player"):
			body.take_damage(1)

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player_bullet"):
		take_damage(1)
