extends Control

func show_game_over():
	visible = true
	get_tree().paused = true  # freeze gameplay

func _on_game_manager_game_over() -> void:
	show_game_over()
	$GameOver.play()

func _on_title_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title_menu.tscn")

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
