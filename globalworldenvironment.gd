extends WorldEnvironment

@export var id: int

func _process(delta: float) -> void:
	if not vars.bloom:
		environment.glow_enabled = false
	else:
		environment.glow_enabled = true
	if not vars.ssao:
		environment.ssao_enabled = false
	else:
		environment.ssao_enabled = true
	if not id == 9:
		environment.fog_sun_scatter = vars.sun_scatter
