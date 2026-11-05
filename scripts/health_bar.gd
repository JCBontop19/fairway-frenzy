extends Node2D

@export var width: float = 24.0
@export var height: float = 4.0
@export var y_offset: float = -80
@export var bar_color: Color = Color(0.2, 1.0, 0.2)
@export var show_when_full: bool = true

@export var max_value: float = 10.0:
	set(value):
		max_value = max(1.0, value)
		current_value = clamp(current_value, 0.0, max_value)
		queue_redraw()

@export var current_value: float = 10.0:
	set(value):
		current_value = clamp(value, 0.0, max_value)
		queue_redraw()

func _ready() -> void:
	position = Vector2(0, y_offset)

func _process(_delta: float) -> void:
	position = Vector2(0, y_offset)

func _draw() -> void:
	if max_value <= 0.0:
		return
	if not show_when_full and current_value >= max_value:
		return

	var ratio: float = clamp(current_value / max_value, 0.0, 1.0)

	var bg_rect := Rect2(
		Vector2(-width * 0.5, -height * 0.5),
		Vector2(width, height)
	)

	var fg_rect := Rect2(
		bg_rect.position,
		Vector2(width * ratio, height)
	)

	draw_rect(bg_rect, Color(0, 0, 0, 0.7))
	draw_rect(fg_rect, bar_color)
