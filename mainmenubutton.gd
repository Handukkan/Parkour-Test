extends Button

@export var id: int
@export var MainMenuParent: CanvasLayer
@export var Animate: AnimationPlayer
@export var AnimateExtra: AnimationPlayer

func _on_button_pressed() -> void:
	match id:
		0:
			Animate.play("start_clicked")
		1:
			Animate.play("button/start_clicked")
		2:
			Animate.play("button/options_clicked")
		3:
			Animate.play("button/quit_clicked")
		4:
			Animate.play("button/reset")
			AnimateExtra.play("button/reset_2")
