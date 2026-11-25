extends Area3D

@export var id: int
@export var button_pressed: bool

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Rigids"):
		button_pressed = true
		button_press()
	if body.is_in_group("notheavy"):
		$Label3D.visible = true
		await get_tree().create_timer(5).timeout
		$Label3D.visible = false

func _physics_process(delta: float) -> void:
	match button_pressed:
		true:
			$Model/MeshInstance3D/MeshInstance3D.position.y = 0.051
		false:
			$Model/MeshInstance3D/MeshInstance3D.position.y = 0.112

func button_press():
	$AudioStreamPlayer3D.play()
	if id == 0:
		$"../../../Door/AnimationPlayer".play("Door")
	if id == 1:
		$"../../../MeshInstance3D18/AnimationPlayer".play("doorawal")
	if id == 2:
		$"../..".button1_pressed = true
	if id == 3:
		$"../..".button2_pressed = true
	if id == 4:
		$"../../..".buttons1_pressed()
	if id == 5:
		$"../../..".buttons2_pressed()
	if id == 6:
		$"../..".button_first_pressed = true
	if id == 7:
		$"../../..".building2_fall()
	if id == 8:
		$"../../Door/AnimationPlayer".play("Door")
	if id == 9:
		$"../../Maze/Mesh/MeshInstance3D30/Door/AnimationPlayer".play("Door")
	if id == 10:
		$AnimationPlayerplat.play("platformnaik")
	button_pressed = true

func button_release():
	if id == 0:
		$"../../../Door/AnimationPlayer".play_backwards("Door")
	if id == 1:
		$"../../../MeshInstance3D18/AnimationPlayer".play_backwards("doorawal")
	if id == 2:
		$"../..".button1_pressed = false
	if id == 3:
		$"../..".button2_pressed = false
	if id == 4:
		$"../../..".button1_release()
	if id == 5:
		$"../../..".button2_released()
	if id == 8:
		$"../../Door/AnimationPlayer".play_backwards("Door")
	if id == 9:
		$"../../Maze/Mesh/MeshInstance3D30/Door/AnimationPlayer".play_backwards("Door")
	if id == 10:
		$AnimationPlayerplat.play_backwards("platformnaik")
	button_pressed = false

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Rigids"):
		button_pressed = false
		button_release()
