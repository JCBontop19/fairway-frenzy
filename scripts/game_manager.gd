extends Node

@export var player_scene: PackedScene
@export var player_spawn_position: Vector2 = Vector2(200, 540)
@export var enemy_basic_scene: PackedScene
@export var enemy_fast_scene: PackedScene
@export var enemy_water_laser_scene: PackedScene
@export var enemy_sand_scene: PackedScene
@export var enemy_tee_scene: PackedScene
@export var enemy_boss_flag_scene: PackedScene
@export var health_pickup_scene: PackedScene
@export var rapid_pickup_scene: PackedScene
@export var shield_pickup_scene: PackedScene
@export var ult_required_charge: int = 60

var ult_charge: int = 0
var player_ult_bar: Node2D = null

signal ult_charge_changed(current, required)

const PICKUP_DROP_CHANCE := 0.25  # 25% chance, tweak as you like

var rng := RandomNumberGenerator.new()

var player_health_bar: Node2D = null
var hit_limits = [3, 4, 5]
var life_stage = 0
var hits_this_life = 0
var total_hits = 0
var score = 0
var current_hole = 1
var enemies_alive = 0

var hole_data := [
	
	{
		"waves": [
			{"type": "basic", "spawn_x_offset": 150, "spawn_y": 540, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 550, "spawn_y": 840, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 650, "spawn_y": 240, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 750, "spawn_y": 740, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 850, "spawn_y": 340, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 950, "spawn_y": 640, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1050, "spawn_y": 440, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1200, "spawn_y": 540, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "basic", "spawn_x_offset": 150, "spawn_y": 900, "path": "ascending"},
			{"type": "basic", "spawn_x_offset": 350, "spawn_y": 1000, "path": "ascending"},
			{"type": "basic", "spawn_x_offset": 550, "spawn_y": 1100, "path": "ascending"},
			{"type": "basic", "spawn_x_offset": 750, "spawn_y": 1200, "path": "ascending"},
			{"type": "basic", "spawn_x_offset": 950, "spawn_y": 1300, "path": "ascending"},
			{"type": "basic", "spawn_x_offset": 1150, "spawn_y": 1400, "path": "ascending"},
			{"type": "basic", "spawn_x_offset": 250, "spawn_y": 300, "path": "descending"},
			{"type": "basic", "spawn_x_offset": 450, "spawn_y": 200, "path": "descending"},
			{"type": "basic", "spawn_x_offset": 650, "spawn_y": 100, "path": "descending"},
			{"type": "basic", "spawn_x_offset": 850, "spawn_y": 0, "path": "descending"},
			{"type": "basic", "spawn_x_offset": 1050, "spawn_y": -100, "path": "descending"},
			{"type": "basic", "spawn_x_offset": 1250, "spawn_y": -200, "path": "descending"}
		]
	},
	{
		"waves": [
			{"type": "water_laser", "spawn_x_offset": 100, "spawn_y": 200, "path": "water_laser"},
			{"type": "water_laser", "spawn_x_offset": 100, "spawn_y": 800, "path": "water_laser"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 300, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 500, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 700, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 550, "spawn_y": 300, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 550, "spawn_y": 500, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 550, "spawn_y": 700, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "water_laser", "spawn_x_offset": 100, "spawn_y": 200, "path": "water_laser"},
			{"type": "water_laser", "spawn_x_offset": 100, "spawn_y": 500, "path": "water_laser"},
			{"type": "water_laser", "spawn_x_offset": 100, "spawn_y": 800, "path": "water_laser"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 300, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 400, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 750, "spawn_y": 300, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 750, "spawn_y": 400, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 600, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 200, "spawn_y": 700, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 750, "spawn_y": 600, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 750, "spawn_y": 700, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 350, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 600, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 2000, "spawn_y": 300, "path": "descending"},
			{"type": "sand", "spawn_x_offset": 2000, "spawn_y": 650, "path": "ascending"},
			{"type": "water_laser", "spawn_x_offset": 1250, "spawn_y": 450, "path": "water_laser"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 200, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 300, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 400, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 500, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 600, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 700, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 350, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 550, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 750, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 2750, "spawn_y": 700, "path": "ascending"},
			{"type": "sand", "spawn_x_offset": 2750, "spawn_y": 200, "path": "descending"},
			{"type": "water_laser", "spawn_x_offset": 2000, "spawn_y": 300, "path": "water_laser"},
			{"type": "water_laser", "spawn_x_offset": 2250, "spawn_y": 600, "path": "water_laser"},
			{"type": "basic", "spawn_x_offset": 1300, "spawn_y": 280, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1200, "spawn_y": 360, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1100, "spawn_y": 420, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 500, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1000, "spawn_y": 580, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1100, "spawn_y": 660, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1200, "spawn_y": 740, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1300, "spawn_y": 820, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 300, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 540, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 780, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 500, "spawn_y": 200, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 500, "spawn_y": 880, "path": "straight"},
			
			{"type": "tee", "spawn_x_offset": 1000, "spawn_y": 540, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1250, "spawn_y": 300, "path": "straight"},
			{"type": "basic", "spawn_x_offset": 1250, "spawn_y": 780, "path": "straight"},

			{"type": "water_laser", "spawn_x_offset": 1750, "spawn_y": 540, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 2000, "spawn_y": 300, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 2000, "spawn_y": 780, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "basic", "spawn_x_offset": 150, "spawn_y": 200, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 150, "spawn_y": 400, "path": "straight"},
			{"type": "tee",  "spawn_x_offset": 150, "spawn_y": 600, "path": "straight"},
			{"type": "water_laser", "spawn_x_offset": 150, "spawn_y": 800, "path": "straight"},
			
			{"type": "water_laser", "spawn_x_offset": 750, "spawn_y": 450, "path": "straight"},
			{"type": "water_laser", "spawn_x_offset": 750, "spawn_y": 650, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 500, "spawn_y": 300, "path": "straight"},
			{"type": "sand", "spawn_x_offset": 500, "spawn_y": 780, "path": "straight"},
			
			{"type": "tee", "spawn_x_offset": 1500, "spawn_y": 300, "path": "straight"},
			{"type": "tee", "spawn_x_offset": 1500, "spawn_y": 540, "path": "straight"},
			{"type": "tee", "spawn_x_offset": 1500, "spawn_y": 780, "path": "straight"},
			{"type": "club", "spawn_x_offset": 1250, "spawn_y": 200, "path": "straight"},
			{"type": "club", "spawn_x_offset": 1250, "spawn_y": 880, "path": "straight"}
		]
	},
	{
		"waves": [
			{"type": "boss_flag", "spawn_x_offset": 200, "spawn_y": 540, "path": "boss"}
		]
	}
]

signal score_changed(new_score)
signal game_over()
signal hit_progress_changed(stage, hits, stage_limit, total)

func _ready():
	rng.randomize()
	call_deferred("_spawn_player")
	call_deferred("start_hole", 1)
	_emit_hit_progress()

func start_hole(hole):
	current_hole = hole
	enemies_alive = 0
	var waves = hole_data[hole - 1]["waves"]
	var w = get_viewport().size.x

	for wave in waves:
		var pos = Vector2(w + wave["spawn_x_offset"], wave["spawn_y"])
		_spawn_enemy_at(wave["type"], pos, wave["path"])

func _spawn_enemy_at(enemy_type, pos: Vector2, path_type: String):
	var enemy = _create_enemy(enemy_type)
	if enemy == null:
		return
	enemy.global_position = pos
	enemy.path_type = path_type
	get_tree().current_scene.add_child(enemy)
	enemies_alive += 1

func _create_enemy(enemy_type):
	match enemy_type:
		"basic":
			return enemy_basic_scene.instantiate()
		"basic_fast":
			return enemy_fast_scene.instantiate()
		"water_laser":
			return enemy_water_laser_scene.instantiate()
		"sand":
			return enemy_sand_scene.instantiate()
		"tee":
			return enemy_tee_scene.instantiate()
		"boss_flag":
			return enemy_boss_flag_scene.instantiate()
		_:
			return null

func play_enemy_death_sfx() -> void:
	$enemyDeath.play()

func register_hit(amount := 1):
	total_hits += amount
	hits_this_life += amount
	var limit = hit_limits[life_stage]

	if life_stage < hit_limits.size() - 1:
		if hits_this_life >= limit:
			_next_life()
	else:
		if hits_this_life >= limit:
			_final_death()

	_update_player_health_bar()
	_emit_hit_progress()

func _next_life():
	$nextLife.play()
	hits_this_life = 0
	life_stage += 1

	_update_player_health_bar()

	var p = _get_player()
	if p:
		p.activate_invincibility()

func _final_death():
	var p = _get_player()
	if p:
		p.queue_free()
	emit_signal("game_over")

func _get_score_multiplier() -> float:
	match life_stage:
		0: return 1.0   # first life
		1: return 0.75  # second life
		2: return 0.5   # final life
		_: return 1.0

func _spawn_player():
	if player_scene == null:
		return
	var p = player_scene.instantiate()
	if p == null:
		return
	p.name = "Player"
	p.global_position = player_spawn_position
	get_tree().current_scene.add_child.call_deferred(p)
	if p.has_method("activate_invincibility"):
		p.activate_invincibility()

	var hb = p.get_node_or_null("HealthBar2D")
	if hb == null:
		hb = p.get_node_or_null("HealthBar")
	if hb == null:
		hb = p.get_node_or_null("PlayerSprite/HealthBar2D")
	player_health_bar = hb
	if player_health_bar != null:
		_update_player_health_bar()

	if p.has_node("UltBar"):
		player_ult_bar = p.get_node("UltBar")
		_update_ult_bar()

func _update_player_health_bar() -> void:
	if player_health_bar == null:
		return

	var limit = hit_limits[life_stage]
	var remaining = max(limit - hits_this_life, 0)

	if player_health_bar.has_method("set_max_value"):
		player_health_bar.set_max_value(limit)
		player_health_bar.set_current_value(remaining)
	else:
		player_health_bar.max_value = limit
		player_health_bar.current_value = remaining

func _get_player():
	return get_tree().current_scene.get_node_or_null("Player")

func _emit_hit_progress():
	var limit = hit_limits[life_stage]
	emit_signal("hit_progress_changed", life_stage, hits_this_life, limit, total_hits)

func enemy_defeated(points: int = 100) -> void:
	var mult = _get_score_multiplier()
	var adjusted_points = floor(points * mult)

	add_score(adjusted_points)

	enemies_alive -= 1
	if enemies_alive <= 0:
		_hole_complete()

func add_score(points):
	score += points
	emit_signal("score_changed", score)

func _hole_complete():
	var ui = get_tree().current_scene.get_node("UIManager")
	if ui:
		ui.show_hole_complete(current_hole)
	if current_hole < hole_data.size():
		await get_tree().create_timer(2.0).timeout
		start_hole(current_hole + 1)
	else:
		ui = get_tree().current_scene.get_node("WinMenu")
		if ui:
			ui.show_win_screen(score)

func pickup_health() -> void:
	hits_this_life = 0
	_update_player_health_bar()

func pickup_rapid() -> void:
	var p = _get_player()
	if p and p.has_method("activate_rapid_fire"):
		p.activate_rapid_fire(6.0, 0.4)

func pickup_shield() -> void:
	var p = _get_player()
	if p and p.has_method("activate_invincibility"):
		p.activate_invincibility(3.0)

func maybe_spawn_pickup(pos: Vector2) -> void:
	if rng.randf() > PICKUP_DROP_CHANCE:
		return

	var which := rng.randi_range(0, 2)
	var scene: PackedScene = null

	match which:
		0:
			scene = health_pickup_scene
		1:
			scene = rapid_pickup_scene
		2:
			scene = shield_pickup_scene

	if scene == null:
		return

	var p = scene.instantiate()
	p.global_position = pos

	get_tree().current_scene.call_deferred("add_child", p)

func add_ult_charge(amount: int) -> void:
	ult_charge = clamp(ult_charge + amount, 0, ult_required_charge)
	_update_ult_bar()
	emit_signal("ult_charge_changed", ult_charge, ult_required_charge)

func can_use_ult() -> bool:
	return ult_charge >= ult_required_charge

func consume_ult_charge() -> void:
	ult_charge = 0
	_update_ult_bar()
	emit_signal("ult_charge_changed", ult_charge, ult_required_charge)

func _update_ult_bar() -> void:
	if player_ult_bar == null:
		return

	if player_ult_bar.has_method("set_max_value"):
		player_ult_bar.set_max_value(ult_required_charge)
		player_ult_bar.set_current_value(ult_charge)
	else:
		player_ult_bar.max_value = ult_required_charge
		player_ult_bar.current_value = ult_charge
