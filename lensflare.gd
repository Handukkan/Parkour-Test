extends TextureRect

const SUN_RAYCAST_LENGTH: float = 750.0

@export var sun: DirectionalLight3D
@export var camera: Camera3D

var target_tint := Vector3(1.4, 1.2, 1.0)
var current_tint := Vector3(0.0, 0.0, 0.0)
var tint_speed := 15.0

func _physics_process(delta: float) -> void:
	if not sun or not camera:
		return
	if not vars.lens_flare:
		hide()
	else:
		show()

	var sun_direction := sun.global_transform.basis.z
	var effective_sun_position := camera.global_position + sun_direction * maxf(camera.near, 1.0)
	var sun_to_camera := effective_sun_position - camera.global_position
	var dot_facing := camera.global_transform.basis.z.dot(sun_to_camera.normalized())

	# Cegah flare muncul kalau matahari di belakang kamera
	if dot_facing > 0.0:
		target_tint = Vector3(0.0, 0.0, 0.0)
	else:
		if visible:
			if _can_see_sun(sun_direction):
				target_tint = Vector3(0.912, 0.847, 0.775)
			else:
				target_tint = Vector3(0.0, 0.0, 0.0)

	current_tint = current_tint.lerp(target_tint, delta * tint_speed)

	var sun_screen_position := camera.unproject_position(effective_sun_position)

	if material is ShaderMaterial:
		material.set_shader_parameter("tint", current_tint)
		material.set_shader_parameter("sun_position", sun_screen_position)


func _can_see_sun(dir: Vector3) -> bool:
	var origin := camera.global_position
	var end := origin + dir * SUN_RAYCAST_LENGTH

	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var result := space_state.intersect_ray(query)

	return result.is_empty()
