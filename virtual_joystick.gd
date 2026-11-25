extends VirtualJoystick

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("UpArrow"):
		$Run.show()
	else:
		$Run.hide()
