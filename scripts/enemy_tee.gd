extends CharacterBody2D

@export var enter_speed := 180
@export var dash_speed := 900
@export var dash_time := 0.3
@export var windup_time := 0.4
@export var max_health := 10
@export var path_type := "straight"
@onready var health_bar: Node2D = $HealthBar

var health := 0
var state := "entering"
var dash_dir := Vector2.LEFT

func _ready():
	health = max_health
	state = "entering"
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.current_value = health

func _physics_process(delta):
	match state:
		"entering":
			_entering(delta)
		"windup":
			pass
		"dashing":
			_dashing(delta)
		"exiting":
			_exiting(delta)

func _entering(delta):
	position.x -= enter_speed * delta

	if position.x < get_viewport().size.x - 400:
		state = "windup"
		$WindupTimer.start(windup_time)

func _on_windup_timer_timeout():
	dash_dir = Vector2.LEFT
	state = "dashing"
	$DashCooldownTimer.start(dash_time)

func _dashing(delta):
	velocity = dash_dir * dash_speed
	move_and_collide(velocity * delta)
	
	if not $ScreenNotifier.is_on_screen():
		_end_dash()

func _on_dash_cooldown_timer_timeout():
	_end_dash()

func _end_dash():
	state = "exiting"
	velocity = Vector2.LEFT * enter_speed

func _exiting(delta):
	position.x -= enter_speed * delta

	if position.x < -200:
		position.x = get_viewport().size.x + 200
		state = "entering"

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
			gm.enemy_defeated(550)

		queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		print("TEE HIT PLAYER")   # debug
		body.take_damage(3)

func _flash():
	modulate = Color(0.60, 0.0, 0.15, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)
