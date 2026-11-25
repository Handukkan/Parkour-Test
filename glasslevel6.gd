extends StaticBody3D

func breakaxe():
	$"..".visible = false
	$CollisionShape3D.disabled = true
	$"../AudioStreamPlayer3D".play()
