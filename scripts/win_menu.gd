extends CanvasLayer

var final_score := 0

func show_win_screen(score: int):
	final_score = score
	visible = true
	get_tree().paused = true
	get_node("VBoxContainer/ScoreLabel").text = "Final Score: " + str(score)
	$winMusic.play()

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/title_menu.tscn")
