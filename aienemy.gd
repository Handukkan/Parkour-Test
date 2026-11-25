extends CharacterBody3D

@export var speed := 5
@export var player: Node3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta):
	if player == null:
		return
	
	# Update target
	nav_agent.target_position = player.global_transform.origin

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_transform.origin)

	# Biar gak terbang naik turun
	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Gravity default Godot
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if player == null:
			return
		player.damage_player_health(100)
		$Dead.play() # Replace with function body.
