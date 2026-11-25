extends ColorRect # atau ColorRect kalo 2D post-process

@export var player_path: NodePath  # Drag player node di inspector biar gampang
@export var velocity_multiplier: float = 0.01  # Adjust ini: 0.01-0.05 biasanya pas, test sendiri
@export var max_blur_strength: float = 3.0
var blur_strength # Cap biar ga over-blur

var player: CharacterBody3D # Ganti ke CharacterBody2D kalo 2D
var last_player_pos: Vector3  # Buat smooth velocity kalo perlu

func _ready():
	player = get_node(player_path)  # Atau hardcode: player = get_node("../Player")

func _process(delta):
	if not player:
		return

# Ambil velocity player (langsung dari body, paling akurat)
	var velocity = player.velocity  # Vector3 buat 3D, Vector2 buat 2D

# Hitung "maju mundur" = speed ke arah forward kamera/player
	var forward_dir = -player.transform.basis.z.normalized()  # Sesuaikan: kalo 2D pake Vector2(1,0) atau input dir
	var forward_speed = velocity.dot(forward_dir)  # Positive = maju, negative = mundur
	var y_dir = -player.transform.basis.y.normalized()
	var y_speed = velocity.dot(y_dir)
	
# Abs kalo lu mau blur sama aja maju/mundur, atau keep sign kalo mau directional
	y_speed = abs(y_speed)
# Kali multiplier + clamp
	blur_strength = clamp(y_speed + forward_speed * velocity_multiplier, 0.0, max_blur_strength)

# Pass ke shader material (ganti "blur_strength" sesuai nama uniform di shader lu)
	material.set_shader_parameter("intensity", blur_strength)

# Optional: smooth lerp biar ga jittery
	# blur_strength = lerp(material.get_shader_parameter("blur_strength", 0.0), blur_strength, delta * 10.0)
	
	if not vars.motion_blur:
		hide()
	else:
		show()
