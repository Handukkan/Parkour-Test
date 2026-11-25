extends Control

func _process(delta: float) -> void:
	if not vars.gamepad_connected:
		show()
	else:
		hide()
