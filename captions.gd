extends Control

func show_text(text: String) -> void:
	$Label.text = text
	show()
	await get_tree().create_timer(2.5).timeout
	hide()
