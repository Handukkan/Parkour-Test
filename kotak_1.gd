extends StaticBody3D

func breakaxe():
	$MeshInstance3D2.queue_free()
	$CollisionShape3D2.disabled = true
	$AudioStreamPlayer3D.play()
