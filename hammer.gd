extends StaticBody3D

@export var player: Node3D
@onready var joint: HingeJoint3D = $Handle/HingeJoint3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player.damage_player_health(100.0)

func _ready() -> void:
	joint.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
	joint.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, 10)
	joint.set_param(HingeJoint3D.PARAM_MOTOR_MAX_IMPULSE, 50)
	
