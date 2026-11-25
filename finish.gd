extends Area3D

@export var id: int

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		finish()

func finish():
	get_tree().change_scene_to_file("res://main_menu.tscn")
	if id == 0:
		if vars.level <= 2:
			vars.level = 2
	if id == 1:
		if vars.level <= 3:
			vars.level = 3
	if id == 2:
		if vars.level <= 4:
			vars.level = 4
	if id == 3:
		if vars.level <= 5:
			vars.level = 5
	if id == 4:
		if vars.level <= 6:
			vars.level = 6
	if id == 5:
		if vars.level <= 7:
			vars.level = 7
	if id == 6:
		if vars.level <= 8:
			vars.level = 8
	if id == 7:
		if vars.level <= 9:
			vars.level = 9
	vars.save_game()
