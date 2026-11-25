extends Node3D

@export var tilt_amount := 3.0
@export var sway_amount := 0.03

@export var pos_smooth := 6.0
@export var rot_smooth := 8.0

# Landing effect
var landing_offset := 0.0
var landing_velocity := 0.0
@export var landing_strength := 0.22     # Sesuaikan selera (0.15 \~ 0.3)
@export var landing_recover := 10.0      # Semakin besar = semakin cepat kembali

# Inertia & sway
var last_speed := 0.0
@export var accel_influence := 0.025

@export var rotation_lag := 5.0
var last_basis := Basis()

var current_pos := Vector3.ZERO
var current_rot := Vector3.ZERO

func _process(delta: float) -> void:
	var player = get_parent().get_parent() as CharacterBody3D
	if not player:
		return
	
	var velocity = player.velocity

	# Sway berdasarkan arah gerak
	var strafe = velocity.dot(player.transform.basis.x)
	var forward = velocity.dot(player.transform.basis.z)

	var target_pos = Vector3(
		-strafe * sway_amount,
		0,
		forward * sway_amount
	)

	var target_rot = Vector3(
		forward * 0.5,          # sedikit pitch ke depan saat maju
		0,
		-strafe * tilt_amount   # roll saat strafing
	)

	# Rotation lag (inertia feel)
	var target_basis = player.transform.basis
	last_basis = last_basis.slerp(target_basis, delta * rotation_lag)
	var relative_basis = last_basis.inverse() * target_basis
	var lag_rot = relative_basis.get_euler()

	target_rot.x += rad_to_deg(lag_rot.x)
	target_rot.z += rad_to_deg(lag_rot.z)

	# === LANDING SPRING PHYSICS ===
	landing_velocity += -landing_offset * landing_recover * delta
	landing_offset += landing_velocity * delta
	target_pos.y += landing_offset

	# Smooth lerp
	current_pos = current_pos.lerp(target_pos, delta * pos_smooth)
	current_rot = current_rot.lerp(target_rot, delta * rot_smooth)

	# Accel influence (sedikit dorong ke belakang saat ngegas)
	var speed = velocity.length()
	var accel = (speed - last_speed) / max(delta, 0.001)
	last_speed = speed
	target_pos.z -= accel * accel_influence

	# Apply ke SwayPivot
	position = current_pos
	rotation_degrees = current_rot


# === FUNGSI YANG DIPANGGIL DARI PLAYER SAAT LANDING ===
func on_landed(fall_speed: float) -> void:
	# Semakin keras jatuh → semakin kuat efeknya (tapi dibatasi)
	var force = clamp(fall_speed / 12.0, 0.0, 2.5)
	landing_velocity = -force * landing_strength
