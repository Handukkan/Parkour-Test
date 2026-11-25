extends CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if get_tree():
				get_tree().change_scene_to_file("res://main_menu.tscn")
	await $VideoStreamPlayer.finished
	if get_tree():
		get_tree().change_scene_to_file("res://main_menu.tscn")
