extends RigidBody3D

@export var follow_speed: float = 18.0
@export var max_grab_speed: float = 19.0
@export var release_push_away: float = 0

@export var player: Node3D
@export var teleport_zone: float
@export var barrel: bool
@export var cube: bool
@export var lvl7: bool

var grabbed: bool = false
var target_marker: Marker3D
var grab_offset: Vector3 = Vector3.ZERO
var initial_angular_damp: float


func _ready():
	can_sleep = false
	
	var mat := PhysicsMaterial.new()
	mat.bounce = 0.0
	mat.friction = 1.0
	mat.rough = true
	
	physics_material_override = mat
	contact_monitor = true
	max_contacts_reported = 12
	
	initial_angular_damp = angular_damp
	
	set_collision_layer_value(4, true)
	set_collision_mask_value(4, false)


func grab(marker: Marker3D, offset: Vector3 = Vector3.ZERO):
	if grabbed:
		release()
		return
	
	if player.grabbing:
		return
	
	target_marker = marker
	grabbed = true
	player.grabbing = true
	grab_offset = offset
	
	# Jangan tabrakan dengan player pas dipegang
	set_collision_mask_value(4, false)
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	angular_damp = 999.0
	
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true


func release(throw_impulse: Vector3 = Vector3.ZERO):
	if not grabbed:
		return
	
	grabbed = false
	player.grabbing = false
	target_marker = null
	
	# Reset velocity sebelum collision balik ON
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	angular_damp = initial_angular_damp
	
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
	
	# Geser menjauh dari player biar gak langsung mental pas collision ON
	if player != null:
		var away: Vector3 = global_position - player.global_position
		
		if away.length() > 0.01:
			global_position += away.normalized() * release_push_away
		else:
			global_position += -global_transform.basis.z * release_push_away
	
	set_collision_mask_value(4, true)
	
	if throw_impulse != Vector3.ZERO:
		apply_central_impulse(throw_impulse)


func _physics_process(delta):
	if not grabbed or target_marker == null:
		return
	
	if player == null:
		release()
		return
	
	if player.current_hand != "GrabbingGun":
		release()
		return
	
	if player.dead:
		release()
		return
	
	var target_pos: Vector3 = target_marker.global_position + grab_offset
	var to_target: Vector3 = target_pos - global_position
	
	var desired_velocity: Vector3 = to_target * follow_speed
	desired_velocity = desired_velocity.limit_length(max_grab_speed)
	
	# Ini lebih stabil daripada apply_central_force
	linear_velocity = desired_velocity
	angular_velocity = Vector3.ZERO
	
	# Jaga-jaga kalau physics Godot tiba-tiba kesurupan
	linear_velocity = linear_velocity.limit_length(max_grab_speed)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and grabbed:
		release()
	if lvl7 and body.is_in_group("Enemy") and grabbed:
		release()
