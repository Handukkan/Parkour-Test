extends RigidBody3D

@export var item_name: String
@onready var player: Node = $"../player"
@export var player_ready: Node3D

func _ready():
	# optional: biar gak langsung tidur
	sleeping = false
	can_sleep = false

func interact():
	if player:
		player.add_item_to_active_slot(item_name)
	if player_ready:
		player_ready.add_item_to_active_slot(item_name)
	queue_free()
