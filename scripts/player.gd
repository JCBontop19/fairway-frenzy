extends CharacterBody2D

@export var speed := 400
@export var bullet_scene: PackedScene
@export var fire_rate := 0.3

@export var heavy_bullet_scene: PackedScene
@export var heavy_fire_rate := 1.0

@onready var anim := $AnimatedSprite2D

var shoot_cooldown := 0.0
var shoot_dir := Vector2.RIGHT
var heavy_cooldown := 0.0

var invincible := false
@export var invincible_duration := 1.2
var invincible_timer := 0.0

var base_fire_rate := 0.3
var rapid_active := false
var rapid_timer := 0.0

func _ready():
	add_to_group("player")
	
	var frame_count = anim.sprite_frames.get_frame_count("colors")
	var random_frame = randi() % frame_count
	
	anim.play("colors")
	anim.frame = random_frame
	
	base_fire_rate = fire_rate

func _process(delta):
	_handle_movement()
	_handle_shooting(delta)
	_handle_invincibility(delta)
	_handle_rapid(delta)
	_handle_heavy_shooting(delta)
	_clamp_to_screen()

func _handle_movement():
	var input_vec = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	velocity = input_vec.normalized() * speed
	move_and_slide()

func _handle_shooting(delta: float) -> void:
	var moving := velocity.length() > 0.0

	if moving:
		shoot_cooldown -= delta
		if shoot_cooldown <= 0.0:
			shoot()
			shoot_cooldown = fire_rate

func _handle_heavy_shooting(delta: float) -> void:
	if heavy_bullet_scene == null:
		return

	var gm = get_tree().current_scene.get_node("GameManager")
	if gm == null:
		return

	if Input.is_action_just_pressed("shoot_heavy") and gm.can_use_ult():
		_shoot_heavy()
		gm.consume_ult_charge()

func _handle_rapid(delta: float) -> void:
	if not rapid_active:
		return

	rapid_timer -= delta
	if rapid_timer <= 0.0:
		rapid_active = false
		fire_rate = base_fire_rate

func activate_rapid_fire(duration: float, multiplier: float) -> void:
	if not rapid_active:
		base_fire_rate = fire_rate

	rapid_active = true
	rapid_timer = duration
	fire_rate = base_fire_rate * multiplier

func shoot():
	if bullet_scene:
		var b = bullet_scene.instantiate()
		b.direction = Vector2.RIGHT
		b.global_position = global_position + Vector2(40, 0)
		get_tree().current_scene.add_child(b)
		$swingSound.play()

func _shoot_heavy() -> void:
	var b = heavy_bullet_scene.instantiate()
	b.direction = Vector2.RIGHT
	b.global_position = global_position + Vector2(40, 0)
	get_tree().current_scene.add_child(b)
	$swingSound.play()

func _handle_invincibility(delta):
	if invincible:
		invincible_timer -= delta
		visible = int(invincible_timer * 18) % 2 == 0

		if invincible_timer <= 0:
			invincible = false
			visible = true

func activate_invincibility(duration: float = -1.0) -> void:
	invincible = true
	if duration > 0.0:
		invincible_timer = duration
	else:
		invincible_timer = invincible_duration
	visible = false

func take_damage(amount := 1):
	if invincible:
		return

	_flash()
	$hitSound.play()

	var gm = get_tree().current_scene.get_node_or_null("GameManager")
	if gm:
		gm.register_hit(amount)

func _flash():
	modulate = Color(0.60, 0.0, 0.15, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

func _clamp_to_screen():
	var rect := get_viewport_rect()
	var padx := 55
	var pady := 30

	position.x = clamp(position.x, padx, rect.size.x - padx)
	position.y = clamp(position.y, pady, rect.size.y - pady)
