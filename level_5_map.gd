extends Node3D

var build_fallen: bool

func _ready() -> void:
	$"../player".global_position = $PlayerSpawn.global_position

func _process(delta: float) -> void:
	if build_fallen:
		$Deatharea/CollisionShape3D7.disabled = true
		$Building2/Collisions/CollisionShape3D7.disabled = false

func _on_wood_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") or body.is_in_group("heavy"):
		$Building1/MeshInstance3D3/Timer.start(1)
		await $Building1/MeshInstance3D3/Timer.timeout
		$Building1/MeshInstance3D3/AnimationPlayer.play("wood_fall")

func _on_wood_body_exited(body: Node3D) -> void:
	$Building1/MeshInstance3D3/Timer.stop()

func building2_fall():
	if not build_fallen:
		$GlobalAnimationPlayer.play("Building_collapse")
		build_fallen = true

func call_shake():
	$"../player".shakecam()
