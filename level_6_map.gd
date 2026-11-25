extends Node3D

@export var player: Node3D
var event_glass_break_counter: int
var glass_broked: bool
@export var door_opened: bool

func _ready() -> void:
	player.visible = false
	await get_tree().create_timer(13).timeout

func _on_global_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "wake_":
		player.visible = true
		player.camera.current = true
		player.fix_rot()
		$"../CanvasLayer".show()

func _on_event_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if player.speed >= 5.4:
			event_glass_break_counter += 1

func _process(delta: float) -> void:
	if event_glass_break_counter >= 3 and not glass_broked:
		broke_glass()
	$"../CanvasLayer/Label".text = "Glass counter: " + str(int(event_glass_break_counter))

func broke_glass():
	$Chamber/MeshInstance3D3.visible = false
	$Chamber/collisions/CollisionShape3D5.disabled = true
	$Chamber/Event/AudioStreamPlayer3D.play()
	$"../player".shakecam()
	glass_broked = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if door_opened:
		$build/Door/AnimationPlayer.play_backwards("door")

func _on_area_3d_glaass_body_entered(body: Node3D) -> void:
	if body.is_in_group("rigiditem"):
		body.translate(Vector3(2, 2, 2))
