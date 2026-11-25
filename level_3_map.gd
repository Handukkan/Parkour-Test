extends Node3D

var button1_pressed: bool
var button2_pressed: bool
var buttons: int
var button_mainpres: bool
var printdbug: bool
var gate_opened: bool
@export var player: Node3D

func buttons1_pressed():
	if not button1_pressed:
		buttons += 1
		button1_pressed = true

func buttons2_pressed():
	if not button2_pressed:
		buttons += 1
		button2_pressed = true

func button1_release():
	if button1_pressed:
		buttons -= 1
		button1_pressed = false

func button2_released():
	if button2_pressed:
		buttons -= 1
		button2_pressed = false

func _process(delta: float) -> void:
	if button_mainpres:
		if not printdbug:
			print("mantappu")
			printdbug = true

func _on_area_3dclosegatr_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if gate_opened:
			$GlobalAnimationPlayer.play("gate_big_close")
			gate_opened = false

func shake_player_cam():
	player.shakecam()
