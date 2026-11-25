extends Node

#controllers
var gamepad_connected: bool
var keyboard_connected: bool

#Graphics
var shadows: bool = true
var ssao: bool
var motion_blur: bool
var bloom: bool = true
var lens_flare: bool
var high_res: float = true
var sun_scatter: float = 0.2

#misc
var loading_progress: float
var level: int = 1
var max_level: int = 99
var musicaudiolevel: float = 1.0
var sfxaudiolevel: float = 1.0

@onready var SAVE_DIR := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join(".HikkiVTechnologies/ParkourTest/user")
@onready var save_path: String = SAVE_DIR.path_join("usersave.json")
@onready var confsave: String = SAVE_DIR.path_join("graphics.json")

func _ready() -> void:
	os_get_permission()
	load_game()

func _process(delta: float) -> void:
	if level >= max_level:
		level = max_level

func save_game():
	Saveui.showui()
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var save_data = {
		"gamedata": {
			"level": level
		}
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
	
	var graphics = {
		"Graphics": {
			"lens_flare": lens_flare,
			"bloom": bloom,
			"shadows": shadows,
			"motion_blur": motion_blur,
			"high_res": high_res,
			"ssao": ssao
		},
		"Audio": {
			"sfxaudiolevel": sfxaudiolevel,
			"musicaudiolevel": musicaudiolevel
		}
	}
	var graps = JSON.stringify(graphics, "\t")
	var conf = FileAccess.open(confsave, FileAccess.WRITE)
	if conf:
		conf.store_string(graps)
		conf.close()
	print("game saved!")

func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	var conf = FileAccess.open(confsave, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		file.close()

		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			if parsed.has("gamedata"):
				var gamedata = parsed["gamedata"]
				level = gamedata.get("level", level)
	if conf:
		var text = conf.get_as_text()
		conf.close()

		var parsed = JSON.parse_string(text)
		if typeof(parsed) == TYPE_DICTIONARY:
			if parsed.has("Graphics"):
				var graphics = parsed["Graphics"]
				lens_flare = graphics.get("lens_flare", lens_flare)
				shadows = graphics.get("shadows", shadows)
				bloom = graphics.get("bloom", bloom)
				ssao = graphics.get("ssao", ssao)
				motion_blur = graphics.get("motion_blur", motion_blur)
				high_res = graphics.get("high_res", high_res)
			if parsed.has("Audio"):
				var audio = parsed["Audio"]
				sfxaudiolevel = audio.get("sfxaudiolevel", sfxaudiolevel)
				musicaudiolevel = audio.get("musicaudiolevel", musicaudiolevel)
	print("game loaded!")

func os_get_permission():
	OS.request_permissions()

func reset_save():
	level = 1
	save_game()
