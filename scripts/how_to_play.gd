extends Control

@onready var panel1 = $Panel1
@onready var panel2 = $Panel2
@onready var anim1 : AnimatedSprite2D = get_node("Panel1/PlayerSprite")
@onready var anim2 : AnimatedSprite2D = get_node("Panel1/BulletSprite")

var slide_time := 0.4
var offscreen_x := 1920

func _ready():
	panel2.position.x = offscreen_x

	anim1.play("colors")
	anim2.play("colors")

func _on_next_button_pressed() -> void:
	var tween = create_tween()

	tween.tween_property(panel2, "position:x", 0, slide_time)

func _on_back_button_2_pressed() -> void:
	var tween = create_tween()

	tween.tween_property(panel2, "position:x", offscreen_x, slide_time)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_menu.tscn")
