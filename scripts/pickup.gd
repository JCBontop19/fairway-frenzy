extends Area2D

enum PickupType { HEALTH, RAPID, SHIELD }

@export var type: PickupType = PickupType.HEALTH

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	var gm = get_tree().current_scene.get_node("GameManager")

	match type:
		PickupType.HEALTH:
			if gm.has_method("pickup_health"):
				gm.pickup_health()
		PickupType.RAPID:
			if gm.has_method("pickup_rapid"):
				gm.pickup_rapid()
		PickupType.SHIELD:
			if gm.has_method("pickup_shield"):
				gm.pickup_shield()

	queue_free()
