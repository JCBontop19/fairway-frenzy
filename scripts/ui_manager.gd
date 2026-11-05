extends CanvasLayer

@onready var label_life = $VBoxContainer/LabelLife
@onready var label_hits = $VBoxContainer/LabelHits
@onready var label_total = $VBoxContainer/LabelTotal

var stage_pars = [3, 4, 5]

var stage_names = ["Life 1", "Life 2", "Final Life"]

func _ready():
	var gm = get_tree().current_scene.get_node_or_null("GameManager")
	if gm:
		gm.connect("hit_progress_changed", Callable(self, "_on_hit_progress_changed"))

	update_ui(0, 0, 3, 0)

func _on_hit_progress_changed(stage: int, hits: int, stage_limit: int, total: int):
	update_ui(stage, hits, stage_limit, total)

func update_ui(stage: int, hits: int, stage_limit: int, total_hits: int):
	var total_limit: int = stage_pars[0] + stage_pars[1] + stage_pars[2]  # 3+4+5 = 12

	label_life.text = "%s (Par %d)" % [stage_names[stage], stage_limit]

	label_hits.text = "Hits: %d / %d" % [hits, stage_limit]

	label_total.text = "Total: %d / %d" % [total_hits, total_limit]

func show_hole_complete(hole: int):
	$HoleLabel.text = "Hole %d Complete!" % hole
	$HoleLabel.visible = true

	await get_tree().create_timer(1.8).timeout

	$HoleLabel.visible = false
