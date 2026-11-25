extends HSlider

var bus_index = AudioServer.get_bus_index("Music")

func _ready() -> void:
	value = vars.musicaudiolevel

func _on_value_changed(value: float) -> void:
	var volume_db = linear_to_db(value)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func _on_drag_ended(value_changed: bool) -> void:
	if value_changed:
		vars.musicaudiolevel = value
