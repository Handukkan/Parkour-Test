extends Node3D

var chase_sequence_started: bool

func start_chase():
	if !chase_sequence_started:
		$NavigationRegion3D/Maze/Mesh/MeshInstance3D35/AnimationPlayer.play("gateopen")
		chase_sequence_started = true

func _on_area_start_chase_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		start_chase()
		$"../CanvasLayer/Warning/AnimationPlayer".play("Kedap")
		$"../terror".play()
		$"../ambient".play()
