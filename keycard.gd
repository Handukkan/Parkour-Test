extends StaticBody3D

@export var player: Node3D
@export var captions: Control
@export var id: int
@export var opened: bool

func interact():
	if id == 0:
		if not opened:
			if player.current_hand == "keycardlvl2":
				$"../../MeshInstance3D14/AnimationPlayer".play("door_slkde")
				opened = true
			elif not player.current_hand == "keycardlvl2":
				captions.show_text("You need a keycard level 2!")
	if id == 1:
		if not opened:
			if player.current_hand == "keycardlvl2":
				$"../../Door/AnimationPlayer".play("Door")
				opened = true
			elif not player.current_hand == "keycardlvl2":
				captions.show_text("You need a keycard level 2!")
	if id == 2:
		if not opened:
			if player.current_hand == "keycardlvl2":
				$"../../AnimationPlayer".play("door")
				opened = true
			elif not player.current_hand == "keycardlvl2":
				captions.show_text("You need a keycard level 2!")
	if id == 3:
		captions.show_text("You need a Master Keycard!")
