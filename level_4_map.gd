extends Node3D

var button_first_pressed: bool = false
var flooropened: bool = false

func _process(delta: float) -> void:
	if button_first_pressed and not flooropened:
		$GlobalAnimationPlayer.play("progress1")
		flooropened = true
		await get_tree().create_timer(10).timeout
		$platform5/StaticBody3D/CollisionShape3D2.disabled = true
		$platform5/StaticBody3D/CollisionShape3D3.disabled = true
		$platform5/StaticBody3D/CollisionShape3D4.disabled = true
		$dinding2/Keycard/CollisionShape3D.disabled = false
