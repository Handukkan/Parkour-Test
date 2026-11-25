extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$"../Obstacles/Hammer/Label3D".show()
		$"../Objects/Rigids/Cube2/Label3D".hide()
		vars.sun_scatter = 0.0

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$"../Obstacles/Hammer/Label3D".hide()
		$"../Objects/Rigids/Cube2/Label3D".show()
		vars.sun_scatter = 0.2
