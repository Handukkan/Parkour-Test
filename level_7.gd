extends Node3D

@export var player: Node3D

func _ready() -> void:
	player.position = $level_7_map/PlayerSpawn.global_position

func _process(delta: float) -> void:
	if player.dead:
		$CanvasLayer/DeathScreen/AnimationPlayer.play("death")
		await $CanvasLayer/DeathScreen/AnimationPlayer.animation_finished
		if get_tree():
			get_tree().reload_current_scene()
