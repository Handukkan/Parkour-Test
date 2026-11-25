extends StaticBody3D

var opened: bool

func _process(delta: float) -> void:
	if $"../..".buttons == 2:
		if not opened:
			$AnimationPlayer.play("glass_open")
			opened = true
			$CollisionShape3D.disabled = false
			$Button.disabled = false
	else:
		if opened:
			$AnimationPlayer.play_backwards("glass_open")
			opened = false
			$CollisionShape3D.disabled = true
			$Button.disabled = true
