extends StaticBody3D

var pressed: bool = false

func interact():
	if $"../..".electricity_on:
		if not pressed:
			$"../../MeshInstance3D7/AnimationPlayer".play("liftdown")
			$MeshInstance3D.position.z = -0.096
			pressed = true
	else:
		return

func _process(delta: float) -> void:
	if not $"../..".electricity_on and pressed:
		$"../../MeshInstance3D7/AnimationPlayer".play_backwards("liftdown")
		$MeshInstance3D.position.z = -0.152
		pressed = false
