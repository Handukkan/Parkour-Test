extends StaticBody3D

@export var id: int
@export var player: Node3D
@export var captions: Control

func interact():
	if id == 1:
		if player.current_hand == "Empty":
			player.add_item_to_active_slot("GrabbingGun")
			captions.show_text("GrabbingGun Picked Up.")
			queue_free()
		else:
			captions.show_text("Switch to an Empty inventory first!")
	if id == 2:
		if player.current_hand == "Empty":
			player.add_item_to_active_slot("Axe")
			captions.show_text("Axe picked up.")
			queue_free()
		else:
			captions.show_text("Switch to an Empty inventory first!")
