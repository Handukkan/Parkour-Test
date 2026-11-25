extends Node3D

@onready var player: Node3D = $player

func _process(delta: float) -> void:
	if player.dead:
		$CanvasLayer/DeathScreen/AnimationPlayer.play("death")
		await $CanvasLayer/DeathScreen/AnimationPlayer.animation_finished
		if get_tree():
			get_tree().reload_current_scene()
