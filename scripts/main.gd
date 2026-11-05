extends Node2D

func _ready():
	print("Main scene loaded OK")
	$drivingSound.play()

func _input(event):
	if event.is_action_pressed("pause"):
		var pm = get_node("PauseMenu")

		if not get_tree().paused:
			pm.show_pause_menu()
		else:
			pm.hide_pause_menu()
