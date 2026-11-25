extends Control

var pausedd: bool
var state: String = "Home"

func _ready() -> void:
	$Graphics/Panel/ShadowsBtn.button_pressed = vars.shadows
	$Graphics/Panel/Bloom.button_pressed = vars.bloom
	$"Graphics/Panel/Lens Flare".button_pressed = vars.lens_flare
	$Graphics/Panel/SSAO.button_pressed = vars.ssao
	$Graphics/Panel/MotionBlur.button_pressed = vars.motion_blur
	$"Graphics/Panel/High Resolution".button_pressed = vars.high_res

func _process(delta: float) -> void:
	set_process(true)
	#FUNGSIDASAR
	if Input.is_action_just_pressed("Pause"):
		await get_tree().create_timer(0.1).timeout
		pausedd = true
		print("Paused pressed")
		if vars.gamepad_connected:
			$PausePanel/Panel/Resume.grab_focus()
	if pausedd and Input.is_action_just_pressed("Pause"):
		pausedd = false
	if $PausePanel/Panel/Resume.button_pressed:
		await get_tree().create_timer(0.1).timeout
		pausedd = false
	if $PausePanel/Panel/Options.button_pressed:
		$PausePanel/Panel/Options.disabled = true
		await get_tree().create_timer(0.2).timeout
		if state == "Home":
			state = "HomeOptions"
			if vars.gamepad_connected:
				$HomeOptions/Panel/GraphicsBtn.grab_focus()
		elif state == "HomeOptions":
			state = "Home"
		$PausePanel/Panel/Options.disabled = false
	if $PausePanel/Panel/Exit.button_pressed:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
	#FUNGSIOPTIONS
	if $HomeOptions/Panel/Exit.button_pressed:
		$HomeOptions/Panel/Exit.disabled = true
		await get_tree().create_timer(0.2).timeout
		state = "Home"
		$HomeOptions/Panel/Exit.disabled = false
		if vars.gamepad_connected:
			$PausePanel/Panel/Resume.grab_focus()
	if $HomeOptions/Panel/GraphicsBtn.button_pressed:
		await get_tree().create_timer(0.1).timeout
		state = "GraphicOptions"
		if vars.gamepad_connected:
			$Graphics/Panel/ShadowsBtn.grab_focus()
	if $Graphics/Panel/Exit.button_pressed:
		await get_tree().create_timer(0.1).timeout
		state = "HomeOptions"
		if vars.gamepad_connected:
			$HomeOptions/Panel/GraphicsBtn.grab_focus()
	if $HomeOptions/Panel/AudioBtn.button_pressed:
		await get_tree().create_timer(0.1).timeout
		state = "AudioOptions"
		if vars.gamepad_connected:
			$Audio/Panel/Music.grab_focus()
	if $Audio/Panel/Exit.button_pressed:
		await get_tree().create_timer(0.1).timeout
		state = "HomeOptions"
		if vars.gamepad_connected:
			$HomeOptions/Panel/AudioBtn.grab_focus()
	#Matching
	var tree = get_tree()
	match pausedd:
		true:
			show()
			if tree:
				get_tree().paused = true
		false:
			hide()
			if tree:
				get_tree().paused = false
	match state:
		"Home":
			$PausePanel.show()
			$HomeOptions.hide()
			$Graphics.hide()
		"HomeOptions":
			$HomeOptions.show()
			$Graphics.hide()
			$Audio.hide()
		"GraphicOptions":
			$Graphics.show()
			$HomeOptions.hide()
		"AudioOptions":
			$HomeOptions.hide()
			$Audio.show()
	vars.shadows = $Graphics/Panel/ShadowsBtn.button_pressed
	vars.bloom = $Graphics/Panel/Bloom.button_pressed
	vars.lens_flare = $"Graphics/Panel/Lens Flare".button_pressed
	vars.ssao = $Graphics/Panel/SSAO.button_pressed
	vars.motion_blur = $Graphics/Panel/MotionBlur.button_pressed
	vars.high_res = $"Graphics/Panel/High Resolution".button_pressed
