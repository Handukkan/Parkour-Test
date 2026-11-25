extends CharacterBody3D

# --- References ---
@onready var HEAD = $HEAD
@onready var camera = $HEAD/SwayPivot/Camera3D
@onready var footstep_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var footstep_sounds: Array[AudioStream] = []
@export var footstep_run: AudioStream
@export var Rigidbody: RigidBody3D
@export var lensflare: Node
@onready var raycast: RayCast3D = $HEAD/SwayPivot/Camera3D/RayCast3D
@export var interactbtn: Control
@export var grabbtn: Control
@onready var rigidmarker: Marker3D = $HEAD/SwayPivot/Camera3D/RayCast3D/RigidbodyMarker
@export var controller_ui: Control

# --- Hand nodes map (clean visibility handling) ---
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

# --- Extra juice ---
var air_dir_lock: Vector3 = Vector3.ZERO
@export var MOMENTUM_BOOST := 1.1

var was_on_floor: bool = false

# --- Advanced movement feel ---
var coyote_time := 0.15
var coyote_timer := 0.0

var jump_buffer_time := 0.15
var jump_buffer_timer := 0.0

@export var ACCEL := 10.0
@export var DEACCEL := 14.0
@export var AIR_CONTROL := 0.6

# --- Movement constants ---
@export var SENSITIVITY = 0.27
@export var JOY_SENSITIVITY := 2.0
@export var WALK_SPEED = 6.0
@export var SPRINT_SPEED = 10.5
@export var JUMP_VELOCITY = 13.5
@export var BOB_FREQ := 2.8
@export var BOB_AMP := 0.1
@export var WALK_BOB_INTENSITY := 1.0
@export var SPRINT_BOB_INTENSITY := 1.35
@export var HORIZONTAL_SWAY := 0.035
@export var ROLL_AMOUNT := 0.8

# --- State variables ---
var speed: float = WALK_SPEED
var is_running: bool
var t_bob: float = 0.0
var last_bob_pos: float = 0.0
var active_slot_index: int = 0
@export var NORMAL_FOV : float = 65.0
@export var SPRINT_FOV : float = 90.0
@export var FOV_LERP_SPEED : float = 7.5          # naikin sedikit dari 6.0
@export var LANDING_FOV_PUNCH : float = 4.0       # kekuatan punch saat landing
var stamina: float = 100.0
@export var stamina_max: float = 100.0
@export var stamina_multiplier: float = 15
@export var jump_cost: float = 30.0
@export var jumpbtndisable: TextureRect # 6-12, makin gede makin cepet
var health: float = 100.0
var grabbing: bool = false
@onready var dead: bool

var current_fov : float
var target_fov : float

# --- Inventory (slotin = runtime; vars.player_slotX = persistent/save) ---
@export var current_hand: String
@export var slotin1: String
@export var slotin2: String
var use_curr_h: bool # bila true -> sinkron awal dari vars ke slotin
var GrabbingGunEquipped: bool

func _ready() -> void:
	# Sinkronisasi awal (mis. pada load/new game)
	# Pastikan visual dan current_hand sinkron saat start
	_update_current_hand()
	current_fov = NORMAL_FOV
	target_fov = NORMAL_FOV
	camera.fov = current_fov
	
	#Hand item SCENES
	item_scenes = {
		"Axe": Axe_scene,
		"GrabbingGun": Grabgunscene,
		"keycardlvl2": keycard2
	}

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		rotate_y(deg_to_rad(-event.relative.x * SENSITIVITY))
		HEAD.rotate_x(deg_to_rad(-event.relative.y * SENSITIVITY))
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-65), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not current_hand == "Empty":
		controller_ui.dropbutn()
	if Input.is_action_just_pressed("Switch"):
		active_slot_index += 1
		_update_current_hand()
	if active_slot_index >= 2:
		active_slot_index = 0
		_update_current_hand()
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
	if $HEAD/SwayPivot/Camera3D/AxeRay.is_colliding():
		var obj = $HEAD/SwayPivot/Camera3D/AxeRay.get_collider()
		if obj and current_hand == "Axe" and obj.has_method("breakaxe") and not $HEAD/Hand/Axe/AnimationPlayer.current_animation == "axe_after" :
			interactbtn.show()
			controller_ui.inter()
			if Input.is_action_just_pressed("Interact"):
				$HEAD/Hand/Axe/AnimationPlayer.play("axe_swing")
				await $HEAD/Hand/Axe/AnimationPlayer.animation_finished
				obj.breakaxe()
				$HEAD/Hand/Axe/AnimationPlayer.play("axe_after")
	if health == 0:
		died()
	# baca right analog
	match current_hand:
		"GrabbingGun":
			GrabbingGunEquipped = true
		"Empty":
			GrabbingGunEquipped = false
		"keycardlvl2":
			GrabbingGunEquipped = false
		"Axe":
			GrabbingGunEquipped = false
	$HEAD/SwayPivot/Camera3D/AudioStreamPlayer.volume_linear = velocity.length() * delta * 0.5
	var joy_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var joy_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	# deadzone biar gak drift
	if abs(joy_x) < 0.1:
		joy_x = 0
	if abs(joy_y) < 0.1:
		joy_y = 0

	# kalau ada input stick → rotate
	if joy_x != 0 or joy_y != 0:
		rotate_y(deg_to_rad(-joy_x * JOY_SENSITIVITY * 100 * delta))
		HEAD.rotate_x(deg_to_rad(-joy_y * JOY_SENSITIVITY * 100 * delta))
		HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-65), deg_to_rad(60))
	if not Input.is_action_pressed("Run") and velocity.length() < 0.1 and is_on_floor():
		stamina += 25.0 * delta
	
	if Input.is_action_pressed("Run") and is_on_floor() and velocity.length() > 0.1:
		stamina -= stamina_multiplier * delta
	
	stamina = clamp(stamina, 0, stamina_max)

	# drop button
	if Input.is_action_just_pressed("Drop"):
		drop_current_item()

	# --- Interaction via raycast ---

	# === GRAVITY + JUMP LOGIC (yang sudah ada) ===
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		velocity += get_gravity() * delta
	
	# sticky ground
	if is_on_floor() and velocity.y < -1:
		velocity.y = -2.0
	
	# === LANDING CAMERA EFFECT + FOV PUNCH (FIXED) ===
	if is_on_floor() and not was_on_floor:
		var fall_speed = abs(velocity.y)
		if fall_speed > 6.0:
			$HEAD/SwayPivot.on_landed(fall_speed)
			# punch FOV dipindah ke blok FOV biar aman

	# --- Movement vector + headbob + move_and_slide() ---
	# ... kode kamu yang lain tetap ...
	
	if stamina >= 30.0:
		jumpbtndisable.hide()
		controller_ui.jump()
	else:
		jumpbtndisable.show()
	# simpan input jump
	if Input.is_action_just_pressed("Jump"):
		jump_buffer_timer = jump_buffer_time
	
	jump_buffer_timer -= delta
	
	# eksekusi jump (buffer + coyote)
	if jump_buffer_timer > 0 and coyote_timer > 0 and stamina >= 30.0:
		velocity.y = JUMP_VELOCITY
		
		# momentum boost (parkour feel)
		velocity.x *= MOMENTUM_BOOST
		velocity.z *= MOMENTUM_BOOST
		
		stamina -= jump_cost
		jump_buffer_timer = 0
		coyote_timer = 0
	
	# variable jump (tap vs hold)
	if Input.is_action_just_released("Jump") and velocity.y > 2.0:
		velocity.y *= 0.7
	
	# --- Movement speed ---
	if Input.is_action_pressed("Run") and stamina >= 0.1:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# --- Movement vector ---
	var input_dir := Input.get_vector("LeftArrow", "RightArrow", "UpArrow", "DownArrow")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# lock arah saat lompat
	if is_on_floor() and direction.length() > 0:
		air_dir_lock = direction
	var target_x = direction.x * speed
	var target_z = direction.z * speed
	
	var on_floor = is_on_floor()
	
	if on_floor:
		# --- GROUND ---
		if direction.length() > 0:
			velocity.x = lerp(velocity.x, target_x, ACCEL * delta)
			velocity.z = lerp(velocity.z, target_z, ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, DEACCEL * delta)
			velocity.z = lerp(velocity.z, 0.0, DEACCEL * delta)
	
	else:
		# --- AIR (HYBRID MOMENTUM) ---

		var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
		var current_speed = horizontal_vel.length()

		var current_dir: Vector3

		if current_speed > 0.1:
			current_dir = horizontal_vel.normalized()
		else:
			current_dir = air_dir_lock

		# arah input
		if direction.length() > 0:
			var target_dir = direction.normalized()
	
			# steer (belok halus)
			current_dir = current_dir.lerp(target_dir, AIR_CONTROL * 0.6)
	
			# 🚀 TAMBAH SPEED dikit di udara (INI YANG KURANG TADI)
			current_speed += ACCEL * 3.0 * delta
			current_speed = min(current_speed, SPRINT_SPEED) # biar gak over

		# apply balik
		velocity.x = current_dir.x * current_speed
		velocity.z = current_dir.z * current_speed

		# drag biar gak infinite
		var drag = 0.992
		velocity.x *= drag
		velocity.z *= drag

	# --- Headbob & footsteps sync (FIXED + ROLL WORK) ---
	var current_speed = velocity.length()          # deklarasi SEKALI aja di sini
	
	if is_on_floor() and current_speed > 0.5:
		t_bob += delta * current_speed * 0.9
		camera.transform.origin = _headbob(t_bob, current_speed)
	else:
		t_bob = lerp(t_bob, 0.0, 8.0 * delta)
		camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, 10.0 * delta)
	
	# Reset roll di CAMERA
	if current_speed < 1.0:
		camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, 0.0, 12.0 * delta)

	# Footstep sync
	if is_on_floor() and direction.length() > 0:
		var bob_pos = sin(t_bob * BOB_FREQ) * BOB_AMP
		if last_bob_pos < 0 and bob_pos >= 0:
			if footstep_sound and footstep_sounds.size() > 0:
				if !is_running: # pilih suara random
					var sound = footstep_sounds.pick_random()
					footstep_sound.stream = sound
				else:
					footstep_sound.stream = footstep_run
				footstep_sound.play()
		last_bob_pos = bob_pos
	else:
		last_bob_pos = 0.0
	
	if speed == SPRINT_SPEED:
		is_running = true
	else:
		is_running = false
	
	# --- Apply movement ---
	move_and_slide()
	
	# =============================================
	#             FOV SUPER MANTEP (FIXED)
	# =============================================
	
	var base_target := NORMAL_FOV
	
	if current_speed > 1.0:
		if current_speed < 5.0:
			var t = (current_speed - 1.0) / 4.0
			base_target = lerp(NORMAL_FOV, 76.0, t)
		else:
			var t = (current_speed - 5.0) / (SPRINT_SPEED - 5.0)
			t = clamp(t, 0.0, 1.0)
			base_target = lerp(76.0, SPRINT_FOV, t * 1.05)
	
	# Set target setiap frame
	target_fov = base_target
	
	# === LANDING FOV PUNCH (sekarang work) ===
	if is_on_floor() and not was_on_floor and abs(velocity.y) > 8.0:
		target_fov += LANDING_FOV_PUNCH
	
	# Lerp lebih cepat saat sprint
	var fov_lerp_speed = FOV_LERP_SPEED
	if current_speed > 7.0:
		fov_lerp_speed = FOV_LERP_SPEED * 1.6
	
	current_fov = lerp(current_fov, target_fov, fov_lerp_speed * delta)
	camera.fov = current_fov

	# Update was_on_floor di paling bawah biar punch detection tetap jalan
	was_on_floor = is_on_floor()

func _headbob(time: float, current_speed: float) -> Vector3:
	var pos = Vector3.ZERO
	var intensity = WALK_BOB_INTENSITY
	
	if current_speed > SPRINT_SPEED - 1.0:
		intensity = SPRINT_BOB_INTENSITY
	
	var t = time * BOB_FREQ
	
	# Vertical bob
	pos.y = sin(t) * BOB_AMP * 0.75 * intensity
	pos.y += sin(t * 2.4 + 0.8) * BOB_AMP * 0.28 * intensity
	
	# Horizontal sway
	pos.x = sin(t * 0.8) * HORIZONTAL_SWAY * intensity
	
	# ROLL (FIX: pakai CAMERA biar gak ditimpa SwayPivot)
	var roll = sin(t * 1.2) * ROLL_AMOUNT * intensity * 0.6
	camera.rotation_degrees.z = roll
	
	# Noise kecil biar natural
	pos.y += sin(t * 6.8) * BOB_AMP * 0.055 * intensity
	
	return pos

# --- Vehicle functions ---

# --- Inventory helpers ---

func set_slot(index: int, item_name: String) -> void:
	# Update persistent vars + runtime slotin supaya konsisten
	match index:
		0:
			slotin1 = item_name
		1:
			slotin2 = item_name
	_update_current_hand()

func _update_current_hand() -> void:
	# Ambil dari runtime slotin (karena itu yang dipakai di gameplay)
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
	# Sembunyikan semua nodes dulu
	for n in hand_nodes.values():
		if is_instance_valid(n):
			n.visible = false
	# Tampilkan yang sesuai current_hand jika ada
	if hand_nodes.has(current_hand) and is_instance_valid(hand_nodes[current_hand]):
		hand_nodes[current_hand].visible = true
	# Jika current_hand == "Empty", semua sudah disembunyikan di atas

# --- Optional utility: set slot by name if player picks up item ---
func add_item_to_active_slot(item_name: String) -> void:
	set_slot(active_slot_index, item_name)

# --- Debug helper (panggil ini di console waktu debug) ---
func debug_print_slots() -> void:
	print("active: ", active_slot_index, ". hand: ", current_hand)

func damage_player_health(amount:float):
	health -= amount

func died():
	hide()
	dead = true
	camera.current = false
	Rigidbody.visible = true
	$"../Camera3D".current = true
	lensflare.camera = $"../Camera3D"
	$"../Camera3D".position = position
	$"../CanvasLayer/MobileControls".process_mode = Node.PROCESS_MODE_DISABLED
	$"../CanvasLayer/MobileControls".hide()
	await get_tree().create_timer(0.1).timeout
	process_mode = Node.PROCESS_MODE_DISABLED

func shakecam():
	if not $HEAD/SwayPivot/Camera3D/AnimationPlayer.current_animation == "shake":
		$HEAD/SwayPivot/Camera3D/AnimationPlayer.play("shake")
		Input.start_joy_vibration(0, 0.5, 1.5, 0.3)

func fix_rot():
	HEAD.rotate_y(0)
	rotate_x(0)

func drop_current_item():
	if current_hand == "Empty":
		return
	if raycast.is_colliding() or $HEAD/SwayPivot/Camera3D/AxeRay.is_colliding():
		return
	if not item_scenes.has(current_hand):
		print("Item gak ada scene:", current_hand)
		return
	
	# Instantiate
	var item = item_scenes[current_hand].instantiate()
	get_tree().current_scene.add_child(item)
	
	# Posisi spawn (depan kamera)
	var cam = camera.global_transform
	var drop_pos = cam.origin + (-cam.basis.z * 1.5)
	item.global_transform.origin = drop_pos
	
	# Kasih arah lempar
	if item is RigidBody3D:
		var throw_dir = -cam.basis.z.normalized()
		item.apply_impulse(Vector3.ZERO, throw_dir * 6.0 + Vector3.UP * 2.0)
	
	# Kosongin slot
	set_slot(active_slot_index, "Empty")
