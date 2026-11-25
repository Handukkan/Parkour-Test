extends Control

var packed_scen: PackedScene
var path_to_load: String = ""
var is_loading: bool = false

var progress := []

func muatt(scene: String):
	path_to_load = scene
	is_loading = true
	ResourceLoader.load_threaded_request(path_to_load)
	print("Loading: " + path_to_load)

func _physics_process(delta: float) -> void:
	if not is_loading:
		return
	
	var status = ResourceLoader.load_threaded_get_status(path_to_load, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			vars.loading_progress = progress[0] * 100
		ResourceLoader.THREAD_LOAD_LOADED:
			packed_scen = ResourceLoader.load_threaded_get(path_to_load)
			get_tree().change_scene_to_packed(packed_scen)
			is_loading = false
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Load failed. force closing...")
			get_tree().quit()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Loading Invalid. report to developer..")
			get_tree().quit()
