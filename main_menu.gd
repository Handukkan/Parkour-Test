extends CanvasLayer

@export var state: String = "STARTMenu"

func _ready() -> void:
	vars.load_game()
	$Options/PanelContainer/GraphicalOptions/ShadowsBtn.button_pressed = vars.shadows
	$Options/PanelContainer/GraphicalOptions/Bloom.button_pressed = vars.bloom
	$"Options/PanelContainer/GraphicalOptions/Lens Flare".button_pressed = vars.lens_flare
	$Options/PanelContainer/GraphicalOptions/SSAO.button_pressed = vars.ssao
	$Options/PanelContainer/GraphicalOptions/MotionBlur.button_pressed = vars.motion_blur
	$"Options/PanelContainer/GraphicalOptions/High Resolution".button_pressed = vars.high_res

func _process(delta: float) -> void:
	#STATE
	match state:
		"STARTMenu":
			$STARTMenu.show()
			$Menu.hide()
			$Options.hide()
			$Level_select.hide()
		"Menu":
			$STARTMenu.hide()
			$Menu.show()
			$Options.hide()
			$Level_select.hide()
		"HomeOptions":
			$Menu.hide()
			$Options.show()
			$Options/PanelContainer/HomeOptions.show()
			$Options/PanelContainer/GraphicalOptions.hide()
			$Options/PanelContainer/SoundSettings.hide()
		"GraphicOptions":
			$Menu.hide()
			$Options.show()
			$Options/PanelContainer/HomeOptions.hide()
			$Options/PanelContainer/GraphicalOptions.show()
			$Options/PanelContainer/SoundSettings.hide()
		"AudioOptions":
			$Menu.hide()
			$Options.show()
			$Options/PanelContainer/HomeOptions.hide()
			$Options/PanelContainer/GraphicalOptions.hide()
			$Options/PanelContainer/SoundSettings.show()
		"LevelSelect":
			$Level_select.show()
			$Menu.hide()
			$Options.hide()
	if state == "STARTMenu":
		$TextureRect/AnimationPlayer.play("modulatefull")
		if Input.is_action_just_pressed("START"):
			open_menu()
	else:
		$TextureRect/AnimationPlayer.play("modulategelap")
	#GRAPHICAL
	vars.shadows = $Options/PanelContainer/GraphicalOptions/ShadowsBtn.button_pressed
	vars.bloom = $Options/PanelContainer/GraphicalOptions/Bloom.button_pressed
	vars.lens_flare = $"Options/PanelContainer/GraphicalOptions/Lens Flare".button_pressed
	vars.ssao = $Options/PanelContainer/GraphicalOptions/SSAO.button_pressed
	vars.motion_blur = $Options/PanelContainer/GraphicalOptions/MotionBlur.button_pressed
	vars.high_res = $"Options/PanelContainer/GraphicalOptions/High Resolution".button_pressed

func quit():
	get_tree().quit()

func level_select():
	state = "LevelSelect"
	if vars.gamepad_connected:
		$Level_select/Panel/Level1.grab_focus()

func graphicsopen() -> void:
	state = "GraphicOptions"
	if vars.gamepad_connected:
		$Options/PanelContainer/GraphicalOptions/ShadowsBtn.grab_focus()

func audioopen() -> void:
	state = "AudioOptions"
	if vars.gamepad_connected:
		$Options/PanelContainer/SoundSettings/Music.grab_focus()

func _on_exithome_btn_pressed() -> void:
	open_menu()

func _on_exitg_btn_pressed() -> void:
	open_options()
	vars.save_game()

func _on_level_1_pressed() -> void:
	loader.muatt("uid://l1dhtqji1d6x")
	get_tree().change_scene_to_file("res://loader.tscn")

func _on_level_2_pressed() -> void:
	loader.muatt("res://level_2.tscn")
	get_tree().change_scene_to_file("res://loader.tscn")

func _on_exitlvl_pressed() -> void:
	open_menu()

func _on_level_3_pressed() -> void:
	loader.muatt("uid://du786coyem4p6")
	get_tree().change_scene_to_file("res://loader.tscn")

func open_menu():
	state = "Menu"
	if vars.gamepad_connected:
		$Menu/PlayButton.grab_focus()

func open_options():
	state = "HomeOptions"
	if vars.gamepad_connected:
		$Options/PanelContainer/HomeOptions/GraphicsBtn.grab_focus()
	vars.save_game()

func _on_level_4_pressed() -> void:
	loader.muatt("uid://cwuygps6658k2")
	get_tree().change_scene_to_file("res://loader.tscn")

func _on_level_5_pressed() -> void:
	loader.muatt("uid://dvqtfggc7w1om")
	get_tree().change_scene_to_file("res://loader.tscn")

func _on_level_6_pressed() -> void:
	loader.muatt("uid://cniplsq1ea5ne")
	get_tree().change_scene_to_file("res://loader.tscn")

func _on_level_7_pressed() -> void:
	loader.muatt("uid://c06ip2svjqcls")
	get_tree().change_scene_to_file("res://loader.tscn")

func _on_level_8_pressed() -> void:
	loader.muatt("res://level_8.tscn")
	get_tree().change_scene_to_file("res://loader.tscn")

func reset_data():
	vars.reset_save()

func _on_saweria_donate_pressed() -> void:
	OS.shell_open("https://saweria.co/HikkiV") # Replace with function body.
