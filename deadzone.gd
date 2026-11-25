extends Area3D

@export var player: Node3D
@export var id: int
@export var audio: AudioStreamPlayer3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player.damage_player_health(100.0)
		if id == 1 and audio:
			audio.play()
