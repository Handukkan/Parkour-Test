extends ProgressBar

@onready var player := $"../../player"

func _physics_process(delta: float) -> void:
	max_value = player.stamina_max
	value = player.stamina
