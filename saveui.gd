extends CanvasLayer

func showui():
	show()
	await get_tree().create_timer(2).timeout
	hide()
