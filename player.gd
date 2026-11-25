extends CharacterBody3D

# =========================================================
# REFERENCES
# =========================================================

@onready var HEAD: Node3D = $HEAD
@onready var sway_pivot: Node3D = $HEAD/SwayPivot
@onready var camera: Camera3D = $HEAD/SwayPivot/Camera3D
@onready var footstep_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var raycast: RayCast3D = $HEAD/SwayPivot/Camera3D/RayCast3D
@onready var rigidmarker: Marker3D = $HEAD/SwayPivot/Camera3D/RayCast3D/RigidbodyMarker
@onready var axe_ray: RayCast3D = $HEAD/SwayPivot/Camera3D/AxeRay

@export var footstep_sounds: Array[AudioStream] = []
@export var footstep_run: AudioStream

@export var Rigidbody: RigidBody3D
@export var lensflare: Node
@export var interactbtn: Control
@export var grabbtn: Control
@export var controller_ui: Control
@export var jumpbtndisable: TextureRect

# =========================================================
# HAND / INVENTORY
# =========================================================

@onready var hand_nodes = {
	"test": $AudioStreamPlayer3D,
	"GrabbingGun": $HEAD/Hand/GrabbingGun,
	"keycardlvl2": $HEAD/Hand/keycardlvl2,
	"Axe": $HEAD/Hand/Axe
}

@export var Axe_scene: PackedScene
@export var Grabgunscene: PackedScene
@export var keycard2: PackedScene

var item_scenes := {}

@export var current_hand: String = "Empty"
@export var slotin1: String = "Empty"
@export var slotin2: String = "Empty"

var active_slot_index: int = 0
var GrabbingGunEquipped: bool = false
var grabbing: bool = false

# =========================================================
# LOOK SETTINGS
# =========================================================

@export var SENSITIVITY: float = 0.27
@export var JOY_SENSITIVITY: float = 2.0

# =========================================================
# MOVEMENT SETTINGS
# =========================================================

@export var WALK_SPEED: float = 6.0
@export var SPRINT_SPEED: float = 10.5
@export var JUMP_VELOCITY: float = 13.5

@export var ACCEL: float = 11.0
@export var DEACCEL: float = 16.0
@export var AIR_CONTROL: float = 1.25
@export var MOMENTUM_BOOST: float = 1.08

@export var MAX_PLAYER_SPEED: float = 24.0
@export var MAX_FALL_SPEED: float = 38.0

var speed: float = WALK_SPEED
var is_running: bool = false
var air_dir_lock: Vector3 = Vector3.ZERO

# =========================================================
# JUMP QUALITY
# =========================================================

@export var coyote_time: float = 0.15
@export var jump_buffer_time: float = 0.15

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# =========================================================
# STAMINA / HEALTH
# =========================================================

@export var stamina_max: float = 100.0
@export var stamina_multiplier: float = 15.0
@export var jump_cost: float = 30.0

var stamina: float = 100.0
var health: float = 100.0
@onready var dead: bool = false

# =========================================================
# CAMERA FEEL
# =========================================================

@export var NORMAL_FOV: float = 65.0
@export var SPRINT_FOV: float = 90.0
@export var FOV_LERP_SPEED: float = 8.5
@export var LANDING_FOV_PUNCH: float = 5.0

@export var BOB_FREQ: float = 2.8
@export var BOB_AMP: float = 0.1
@export var WALK_BOB_INTENSITY: float = 1.0
@export var SPRINT_BOB_INTENSITY: float = 1.45
@export var HORIZONTAL_SWAY: float = 0.04
@export var ROLL_AMOUNT: float = 1.2

@export var STRAFE_LEAN_AMOUNT: float = 3.2
@export var SPEED_LEAN_AMOUNT: float = 1.0
@export var LAND_DIP_AMOUNT: float = 0.16
@export var LAND_DIP_RETURN: float = 12.0
@export var CAMERA_SPEED_SHAKE: float = 0.018

var current_fov: float
var target_fov: float

var t_bob: float = 0.0
var last_bob_pos: float = 0.0
var was_on_floor: bool = false
var landing_dip: float = 0.0
var camera_noise_time: float = 0.0

# =========================================================
# READY
# =========================================================

func _ready() -> void:
	_update_current_hand()
	
	current_fov = NORMAL_FOV
	target_fov = NORMAL_FOV
	camera.fov = current_fov

	
	item_scenes = {
		"Axe": Axe_scene,
		"GrabbingGun": Grabgunscene,
		"keycardlvl2": keycard2
	}

# =========================================================
# INPUT
# =========================================================

func _input(event: InputEvent) -> void:
	if dead:
		return
	
	if event is InputEventScreenDrag:
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		HEAD.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-65), deg_to_rad(60))

# =========================================================
# PHYSICS
# =========================================================

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	_handle_ui_and_inventory()
	_handle_interaction()
	_handle_look_controller(delta)
	_handle_stats(delta)
	_handle_jump_and_gravity(delta)
	_handle_movement(delta)
	_handle_camera_feel(delta)
	_handle_footsteps()
	
	move_and_slide()
	
	# Anti-NASA kalau physics Godot tiba-tiba kerasukan
	_clamp_player_velocity()
	
	was_on_floor = is_on_floor()

# =========================================================
# UI / INVENTORY
# =========================================================

func _handle_ui_and_inventory() -> void:
	if current_hand != "Empty":
		controller_ui.dropbutn()
	
	if Input.is_action_just_pressed("Switch"):
		active_slot_index += 1
		
		if active_slot_index >= 2:
			active_slot_index = 0
		
		_update_current_hand()
	
	if Input.is_action_just_pressed("Drop"):
		drop_current_item()
	
	match current_hand:
		"GrabbingGun":
			GrabbingGunEquipped = true
		_:
			GrabbingGunEquipped = false

# =========================================================
# INTERACTION
# =========================================================

func _handle_interaction() -> void:
	interactbtn.hide()
	grabbtn.hide()
	
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		
		if obj and obj.has_method("interact"):
			interactbtn.show()
			controller_ui.inter()
			
			if Input.is_action_just_pressed("Interact"):
				obj.interact()
		
		if obj and current_hand == "GrabbingGun" and obj.has_method("grab"):
			grabbtn.show()
			controller_ui.rtrigger()
			
			if Input.is_action_just_pressed("LeftClick"):
				obj.grab(rigidmarker)
	
	if axe_ray.is_colliding():
		var obj = axe_ray.get_collider()
		
		if obj and current_hand == "Axe" and obj.has_method("breakaxe"):
			if $HEAD/Hand/Axe/AnimationPlayer.current_animation != "axe_after":
				interactbtn.show()
				controller_ui.inter()
				
				if Input.is_action_just_pressed("Interact"):
					_axe_hit(obj)

func _axe_hit(obj: Node) -> void:
	$HEAD/Hand/Axe/AnimationPlayer.play("axe_swing")
	await $HEAD/Hand/Axe/AnimationPlayer.animation_finished
	
	if is_instance_valid(obj):
		obj.breakaxe()
	
	$HEAD/Hand/Axe/AnimationPlayer.play("axe_after")

# =========================================================
# LOOK CONTROLLER
# =========================================================

func _handle_look_controller(delta: float) -> void:
	var joy_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var joy_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	if abs(joy_x) < 0.1:
		joy_x = 0.0
	
	if abs(joy_y) < 0.1:
		joy_y = 0.0
	
	if joy_x != 0.0 or joy_y != 0.0:
		rotate_y(deg_to_rad(-joy_x * JOY_SENSITIVITY * 100.0 * delta))
		HEAD.rotate_x(deg_to_rad(-joy_y * JOY_SENSITIVITY * 100.0 * delta))
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-65), deg_to_rad(60))

# =========================================================
# STATS
# =========================================================

func _handle_stats(delta: float) -> void:
	if health <= 0.0:
		died()
		return
	
	if not Input.is_action_pressed("Run") and velocity.length() < 0.1 and is_on_floor():
		stamina += 25.0 * delta
	
	if Input.is_action_pressed("Run") and is_on_floor() and velocity.length() > 0.1:
		stamina -= stamina_multiplier * delta
	
	stamina = clamp(stamina, 0.0, stamina_max)
	
	if stamina >= 30.0:
		jumpbtndisable.hide()
		controller_ui.jump()
	else:
		jumpbtndisable.show()
	
	$HEAD/SwayPivot/Camera3D/AudioStreamPlayer.volume_linear = velocity.length() * delta * 0.5

# =========================================================
# JUMP / GRAVITY
# =========================================================

func _handle_jump_and_gravity(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		velocity += get_gravity() * delta
	
	if velocity.y < -MAX_FALL_SPEED:
		velocity.y = -MAX_FALL_SPEED
	
	if is_on_floor() and velocity.y < -1.0:
		velocity.y = -2.0
	
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_time
	
	jump_buffer_timer -= delta
	
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0 and stamina >= jump_cost:
		velocity.y = JUMP_VELOCITY
		
		velocity.x *= MOMENTUM_BOOST
		velocity.z *= MOMENTUM_BOOST
		
		stamina -= jump_cost
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
	
	if Input.is_action_just_released("Jump") and velocity.y > 2.0:
		velocity.y *= 0.7
	
	if is_on_floor() and not was_on_floor:
		var land_force = abs(velocity.y)
		
		if land_force > 6.0:
			landing_dip = clamp(land_force / 45.0, 0.05, LAND_DIP_AMOUNT)
			
			if sway_pivot.has_method("on_landed"):
				sway_pivot.on_landed(land_force)

# =========================================================
# MOVEMENT
# =========================================================

func _handle_movement(delta: float) -> void:
	if Input.is_action_pressed("Run") and stamina > 0.1:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	is_running = speed == SPRINT_SPEED
	
	var input_dir := Input.get_vector("LeftArrow", "RightArrow", "UpArrow", "DownArrow")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if is_on_floor() and direction.length() > 0.0:
		air_dir_lock = direction
	
	var target_x = direction.x * speed
	var target_z = direction.z * speed
	
	if is_on_floor():
		if direction.length() > 0.0:
			velocity.x = lerp(velocity.x, target_x, ACCEL * delta)
			velocity.z = lerp(velocity.z, target_z, ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, DEACCEL * delta)
			velocity.z = lerp(velocity.z, 0.0, DEACCEL * delta)
	else:
		var air_accel := ACCEL * AIR_CONTROL
		var target_velocity := direction * speed
		
		if direction.length() > 0.0:
			velocity.x = lerp(velocity.x, target_velocity.x, air_accel * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, air_accel * delta)
		else:
			velocity.x = lerp(velocity.x, velocity.x * 0.98, 2.0 * delta)
			velocity.z = lerp(velocity.z, velocity.z * 0.98, 2.0 * delta)
		
		var horizontal := Vector3(velocity.x, 0.0, velocity.z)
		
		if horizontal.length() > SPRINT_SPEED:
			horizontal = horizontal.limit_length(SPRINT_SPEED)
			velocity.x = horizontal.x
			velocity.z = horizontal.z

# =========================================================
# CAMERA FEEL
# =========================================================

func _handle_camera_feel(delta: float) -> void:
	var horizontal_speed = Vector3(velocity.x, 0.0, velocity.z).length()
	var full_speed = velocity.length()
	
	# Headbob
	if is_on_floor() and horizontal_speed > 0.5:
		t_bob += delta * horizontal_speed * 0.9
		camera.transform.origin = _headbob(t_bob, horizontal_speed)
	else:
		t_bob = lerp(t_bob, 0.0, 8.0 * delta)
		camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, 10.0 * delta)
	
	# Landing dip
	landing_dip = lerp(landing_dip, 0.0, LAND_DIP_RETURN * delta)
	camera.transform.origin.y -= landing_dip
	
	# FOV
	var base_target := NORMAL_FOV
	
	if horizontal_speed > 1.0:
		if horizontal_speed < 5.0:
			var t = (horizontal_speed - 1.0) / 4.0
			base_target = lerp(NORMAL_FOV, 76.0, t)
		else:
			var t = (horizontal_speed - 5.0) / (SPRINT_SPEED - 5.0)
			t = clamp(t, 0.0, 1.0)
			base_target = lerp(76.0, SPRINT_FOV, t * 1.05)
	
	target_fov = base_target
	
	if is_on_floor() and not was_on_floor and abs(velocity.y) > 8.0:
		target_fov += LANDING_FOV_PUNCH
	
	var fov_lerp_speed = FOV_LERP_SPEED
	
	if horizontal_speed > 7.0:
		fov_lerp_speed *= 1.6
	
	current_fov = lerp(current_fov, target_fov, fov_lerp_speed * delta)
	camera.fov = current_fov
	
	# Camera lean / impact
	var input_dir := Input.get_vector("LeftArrow", "RightArrow", "UpArrow", "DownArrow")
	var strafe_lean = -input_dir.x * STRAFE_LEAN_AMOUNT
	
	var speed_lean = 0.0
	if horizontal_speed > WALK_SPEED:
		speed_lean = sin(t_bob * 0.7) * SPEED_LEAN_AMOUNT
	
	var target_roll = strafe_lean + speed_lean
	
	if horizontal_speed < 0.5:
		target_roll = 0.0
	
	camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, target_roll, 9.0 * delta)
	
	# Speed shake halus pas sprint
	camera_noise_time += delta * max(horizontal_speed, 1.0)
	
	if is_on_floor() and horizontal_speed > SPRINT_SPEED * 0.75:
		var shake = sin(camera_noise_time * 7.0) * CAMERA_SPEED_SHAKE
		camera.transform.origin.x += shake

func _headbob(time: float, current_speed: float) -> Vector3:
	var pos = Vector3.ZERO
	var intensity = WALK_BOB_INTENSITY
	
	if current_speed > SPRINT_SPEED - 1.0:
		intensity = SPRINT_BOB_INTENSITY
	
	var t = time * BOB_FREQ
	
	pos.y = sin(t) * BOB_AMP * 0.75 * intensity
	pos.y += sin(t * 2.4 + 0.8) * BOB_AMP * 0.28 * intensity
	
	pos.x = sin(t * 0.8) * HORIZONTAL_SWAY * intensity
	
	pos.y += sin(t * 6.8) * BOB_AMP * 0.055 * intensity
	
	return pos

# =========================================================
# FOOTSTEPS
# =========================================================

func _handle_footsteps() -> void:
	var horizontal_speed = Vector3(velocity.x, 0.0, velocity.z).length()
	var input_dir := Input.get_vector("LeftArrow", "RightArrow", "UpArrow", "DownArrow")
	
	if is_on_floor() and input_dir.length() > 0.0 and horizontal_speed > 0.5:
		var bob_pos = sin(t_bob * BOB_FREQ) * BOB_AMP
		
		if last_bob_pos < 0.0 and bob_pos >= 0.0:
			if footstep_sound:
				if is_running and footstep_run:
					footstep_sound.stream = footstep_run
				elif footstep_sounds.size() > 0:
					footstep_sound.stream = footstep_sounds.pick_random()
				
				footstep_sound.pitch_scale = randf_range(0.94, 1.06)
				footstep_sound.play()
		
		last_bob_pos = bob_pos
	else:
		last_bob_pos = 0.0

# =========================================================
# SAFETY
# =========================================================

func _clamp_player_velocity() -> void:
	var y_vel = velocity.y
	
	velocity.y = 0.0
	velocity = velocity.limit_length(MAX_PLAYER_SPEED)
	velocity.y = clamp(y_vel, -MAX_FALL_SPEED, JUMP_VELOCITY * 1.4)

# =========================================================
# INVENTORY HELPERS
# =========================================================

func set_slot(index: int, item_name: String) -> void:
	match index:
		0:
			slotin1 = item_name
		1:
			slotin2 = item_name
	
	_update_current_hand()

func _update_current_hand() -> void:
	match active_slot_index:
		0:
			current_hand = slotin1
		1:
			current_hand = slotin2
		_:
			current_hand = "Empty"
	
	print("Active slot: ", active_slot_index, ". -> ", current_hand)
	_apply_current_hand_visual()
	debug_print_slots()

func _apply_current_hand_visual() -> void:
	for n in hand_nodes.values():
		if is_instance_valid(n):
			n.visible = false
	
	if hand_nodes.has(current_hand) and is_instance_valid(hand_nodes[current_hand]):
		hand_nodes[current_hand].visible = true

func add_item_to_active_slot(item_name: String) -> void:
	set_slot(active_slot_index, item_name)

func debug_print_slots() -> void:
	print("active: ", active_slot_index, ". hand: ", current_hand)

func drop_current_item() -> void:
	if current_hand == "Empty":
		return
	
	if raycast.is_colliding() or axe_ray.is_colliding():
		return
	
	if not item_scenes.has(current_hand):
		print("Item gak ada scene: ", current_hand)
		return
	
	var item = item_scenes[current_hand].instantiate()
	get_tree().current_scene.add_child(item)
	
	var cam = camera.global_transform
	var drop_pos = cam.origin + (-cam.basis.z * 1.5)
	item.global_transform.origin = drop_pos
	
	if item is RigidBody3D:
		var throw_dir = -cam.basis.z.normalized()
		item.apply_impulse(Vector3.ZERO, throw_dir * 6.0 + Vector3.UP * 2.0)
	
	set_slot(active_slot_index, "Empty")

# =========================================================
# HEALTH / DEATH
# =========================================================

func damage_player_health(amount: float) -> void:
	health -= amount
	health = max(health, 0.0)

func died() -> void:
	if dead:
		return
	
	hide()
	dead = true
	
	camera.current = false
	
	Rigidbody.visible = true
	$"../Camera3D".current = true
	
	if lensflare:
		lensflare.camera = $"../Camera3D"
	
	$"../Camera3D".position = position
	
	$"../CanvasLayer/MobileControls".process_mode = Node.PROCESS_MODE_DISABLED
	$"../CanvasLayer/MobileControls".hide()
	
	await get_tree().create_timer(0.1).timeout
	process_mode = Node.PROCESS_MODE_DISABLED

# =========================================================
# EFFECTS
# =========================================================

func shakecam() -> void:
	if $HEAD/SwayPivot/Camera3D/AnimationPlayer.current_animation != "shake":
		$HEAD/SwayPivot/Camera3D/AnimationPlayer.play("shake")
		Input.start_joy_vibration(0, 0.5, 1.5, 0.3)

func fix_rot() -> void:
	HEAD.rotation.y = 0.0
	rotation.x = 0.0
