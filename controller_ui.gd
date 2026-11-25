extends Control

#References
@export var Jump: TextureRect
@export var Run: TextureRect
@export var Inv: TextureRect
@export var RT: TextureRect
@export var Interact: TextureRect
@export var Drop: TextureRect

#core
var jumpbtn: bool
var rtriggerbtn: bool
var interbtn: bool
var dropbtn: bool

func _process(delta: float) -> void:
	if vars.gamepad_connected:
		show()
	else:
		hide()
	
	#core
	Jump.visible = jumpbtn
	RT.visible = rtriggerbtn
	Interact.visible = interbtn
	Drop.visible = dropbtn
	
	jumpbtn = false
	rtriggerbtn = false
	interbtn = false
	dropbtn = false

func jump():
	jumpbtn = true
func rtrigger():
	rtriggerbtn = true
func inter():
	interbtn = true
func dropbutn():
	dropbtn = true
