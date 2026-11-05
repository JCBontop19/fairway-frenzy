extends Control

@onready var main = get_tree().current_scene

func show_pause_menu():
	visible = true
	get_tree().paused = true

func hide_pause_menu():
	visible = false
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	hide_pause_menu()

func _on_title_button_pressed() -> void:
	hide_pause_menu()
	get_tree().change_scene_to_file("res://Scenes/title_menu.tscn")

func _on_restart_button_pressed() -> void:
	hide_pause_menu()
	get_tree().reload_current_scene()
