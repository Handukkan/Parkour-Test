extends Label

@export var id: int
@onready var player_cam: Camera3D = $"../../player/HEAD/SwayPivot/Camera3D"
@export var color_radial: Control
@onready var player := $"../../player"

func _process(delta: float) -> void:
	if id == 1:
		text = "FOV: " + str(player_cam.fov)
	if id == 2:
		text = "Blur: " + str(color_radial.blur_strength)
	if id == 3:
		text = "Stamina: " + str(player.stamina)
