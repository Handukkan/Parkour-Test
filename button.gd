extends StaticBody3D

@export var disabled: bool

func interact():
	if not disabled:
		$"../../..".button_mainpres = true
		$AudioStreamPlayer3D.play()
		$"../../../GlobalAnimationPlayer".play("gate_big_open")
		$"../../..".gate_opened = true
