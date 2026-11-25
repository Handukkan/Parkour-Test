extends Node

func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	# Cek initial juga
	_check_joypads()

func _on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		print("Controller baru connected: ", Input.get_joy_name(device_id))
		vars.gamepad_connected = true
		print("Controller Connected!")
	else:
		print("Controller ", device_id, " disconnected!")
		vars.gamepad_connected = false
		print("Controller disconnected!")
	_check_joypads()  # Update list

func _check_joypads():
	var joypads = Input.get_connected_joypads()
	print("Total connected: ", joypads.size())
