extends Light3D

func _process(delta: float) -> void:
	match vars.shadows:
		true:
			shadow_enabled = true
		false:
			shadow_enabled = false
