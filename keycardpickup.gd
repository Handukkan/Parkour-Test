extends StaticBody3D

@export var player: Node3D
@export var keycardlevel: int
@export var captions: Control

func interact():
	if player.current_hand == "Empty":
		match keycardlevel:
			2:
				player.add_item_to_active_slot("keycardlvl2")
				captions.show_text("Keycard Level 2 Picked Up.")
		queue_free()
	else:
		captions.show_text("Switch to an Empty inventory first!")
