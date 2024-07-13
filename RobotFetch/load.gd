extends Control
func _ready():
	var loadNOW = await load("res://main.tscn")
	print("Test")
	get_tree().create_tween().tween_property($ColorRect, "modulate", Color(0.0, 0.0, 0.0), 0.8)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(loadNOW)
