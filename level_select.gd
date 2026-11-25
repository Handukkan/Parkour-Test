extends Button

@export var level: int

func _process(delta: float) -> void:
	if vars.level <= level:
		disabled = true
	else:
		disabled = false
