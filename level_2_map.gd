extends Node3D

var button1_pressed: bool = false
var button2_pressed: bool = false
var electricity_on: bool
var power_outage: bool = false
var spikes_down: bool
var ambient_playing: bool
var door_open: bool

func _process(delta: float) -> void:
	match button1_pressed:
		true:
			electricity_on = true
		false:
			electricity_on = false
	match electricity_on:
		true:
			if power_outage:
				$power_on.play(0.1)
				power_outage = false
			if not ambient_playing:
				$Ambient.play()
				ambient_playing = true
			$MeshInstance3D2/MeshInstance3D/Label3D.text = "Power: ON"
			$MeshInstance3D9/OmniLight3D.light_energy = 5
			$MeshInstance3D10/OmniLight3D.light_energy = 5
			$"../player/HEAD/SwayPivot/Camera3D/SpotLight3D".light_energy = 0
		false:
			if not power_outage:
				$Power_outage.play()
				power_outage = true
			if ambient_playing:
				$Ambient.stop()
				ambient_playing = false
			$MeshInstance3D2/MeshInstance3D/Label3D.text = "Power: OFF"
			$MeshInstance3D9/OmniLight3D.light_energy = 0
			$MeshInstance3D10/OmniLight3D.light_energy = 0
			$"../player/HEAD/SwayPivot/Camera3D/SpotLight3D".light_energy = 0.25
	match button2_pressed:
		true:
			if not door_open:
				$Door/AnimationPlayer.play("Door")
				if not spikes_down:
					spikes()
				door_open = true
		false:
			if door_open:
				$Door/AnimationPlayer.play_backwards("Door")
				door_open = false
			
func spikes():
	$MeshInstance3D10/AnimationPlayer.play("Spike")
	await get_tree().create_timer(2).timeout
	$MeshInstance3D10/AnimationPlayer.play_backwards("Spike")
