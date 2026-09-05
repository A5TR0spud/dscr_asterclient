class_name SaveSystem

static var dict: Dictionary = {
	"wordDict": {
		"keys": [
		],
		"values": [
		]
	},
	"descDict": {
		"keys": [
		],
		"values": [
		]
	},
	"beforeUserDefaultMode": 1,
	"afterUserDefaultMode": 1
}

static var settings: Dictionary = {}
static var nicknames: Dictionary = {}
static var library: Dictionary = {}

const _DICT_FOLDER: String = "/dictionaries/"
static var _current_dictionary_filename: String = "DICTIONARY-1.save"
const _SETTINGS_PATH: String = "settings.json"
const _NICKNAMES_PATH: String = "nicknames.json"
const _LIBRARY_PATH: String = "library.json"
const DIRECTORY_PATH: String = "user://directory.txt"
static var opened_save_folder: String = ProjectSettings.globalize_path("user://save/")

static func load_all() -> void:
	load_directory()
	var dicts: String = opened_save_folder.path_join(_DICT_FOLDER)
	if not DirAccess.dir_exists_absolute(dicts):
		DirAccess.make_dir_recursive_absolute(dicts)
	load_dict()
	load_settings()
	load_nicknames()
	load_library()

static func save_directory() -> void:
	var file_access := FileAccess.open(DIRECTORY_PATH, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	
	file_access.store_string(opened_save_folder)
	file_access.close()

static func load_directory() -> void:
	if not FileAccess.file_exists(DIRECTORY_PATH):
		DirAccess.make_dir_recursive_absolute(opened_save_folder.path_join(_DICT_FOLDER))
		save_directory()
		return
	var file_access := FileAccess.open(DIRECTORY_PATH, FileAccess.READ)
	var strig := FileAccess.get_file_as_string(DIRECTORY_PATH)
	file_access.close()
	opened_save_folder = strig

static func open_save_location() -> void:
	OS.shell_show_in_file_manager(opened_save_folder.path_join(_DICT_FOLDER).path_join(_current_dictionary_filename))

static var _file_dialog: FileDialog
static func change_directory_location() -> void:
	if _file_dialog == null:
		_file_dialog = FileDialog.new()
		_file_dialog.set_file_mode(FileDialog.FILE_MODE_OPEN_DIR)
		_file_dialog.set_access(FileDialog.ACCESS_FILESYSTEM)
		_file_dialog.set_use_native_dialog(true)
		_file_dialog.dir_selected.connect(_on_dir_selected)
		Main.instance.add_child(_file_dialog)
	_file_dialog.current_dir = opened_save_folder
	_file_dialog.popup_centered_ratio()

static func _on_dir_selected(new_path):
	var old_path: String = opened_save_folder
	opened_save_folder = new_path
	save_directory()
	var old_dir := DirAccess.open(old_path)
	var new_dir := DirAccess.open(new_path)
	if old_dir and old_dir.file_exists(_LIBRARY_PATH) and not new_dir.file_exists(_LIBRARY_PATH):
		var tmp := FileAccess.open(new_path.path_join(_LIBRARY_PATH), FileAccess.WRITE)
		if tmp:
			tmp.store_string(FileAccess.get_file_as_string(old_path.path_join(_LIBRARY_PATH)))
			old_dir.remove(_LIBRARY_PATH)
			tmp.close()
	if old_dir and old_dir.file_exists(_NICKNAMES_PATH) and not new_dir.file_exists(_NICKNAMES_PATH):
		var tmp := FileAccess.open(new_path.path_join(_NICKNAMES_PATH), FileAccess.WRITE)
		if tmp:
			tmp.store_string(FileAccess.get_file_as_string(old_path.path_join(_NICKNAMES_PATH)))
			old_dir.remove(_NICKNAMES_PATH)
			tmp.close()
	if old_dir and old_dir.file_exists(_SETTINGS_PATH) and not new_dir.file_exists(_SETTINGS_PATH):
		var tmp := FileAccess.open(new_path.path_join(_SETTINGS_PATH), FileAccess.WRITE)
		if tmp:
			tmp.store_string(FileAccess.get_file_as_string(old_path.path_join(_SETTINGS_PATH)))
			old_dir.remove(_SETTINGS_PATH)
			tmp.close()
	var old_dict_dir := DirAccess.open(old_path.path_join(_DICT_FOLDER))
	new_dir.make_dir(_DICT_FOLDER)
	if old_dict_dir:
		var arr: PackedStringArray = old_dict_dir.get_files()
		for old_dict_file: String in arr:
			if FileAccess.file_exists(new_path.path_join(_DICT_FOLDER).path_join(old_dict_file)):
				continue
			var tmp0 := FileAccess.open(old_path.path_join(_DICT_FOLDER).path_join(old_dict_file), FileAccess.READ)
			var tmp := FileAccess.open(new_path.path_join(_DICT_FOLDER).path_join(old_dict_file), FileAccess.WRITE)
			var strig: String = FileAccess.get_file_as_string(old_path.path_join(_DICT_FOLDER).path_join(old_dict_file))
			tmp0.close()
			if tmp:
				tmp.store_string(strig)
				tmp.close()
				old_dict_dir.remove(old_dict_file)
	if old_dict_dir and old_dict_dir.get_files().size() == 0:
		old_dir.remove(_DICT_FOLDER)
	load_all()

static func open_directory_location() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(DIRECTORY_PATH))

static func save_nicknames() -> void:
	var json_string := JSON.stringify(nicknames, "\t")
	var file_access: FileAccess = FileAccess.open(opened_save_folder.path_join(_NICKNAMES_PATH), FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()

static func load_nicknames() -> void:
	if not FileAccess.file_exists(opened_save_folder.path_join(_NICKNAMES_PATH)):
		return
	var file_access := FileAccess.open(opened_save_folder.path_join(_NICKNAMES_PATH), FileAccess.READ)
	var json_string:= FileAccess.get_file_as_string(opened_save_folder.path_join(_NICKNAMES_PATH))
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	nicknames = json.data
	Main.on_nicknames_reload()

static func save_library() -> void:
	var json_string := JSON.stringify(library, "\t")
	var file_access := FileAccess.open(opened_save_folder.path_join(_LIBRARY_PATH), FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()

static func load_library() -> void:
	if not FileAccess.file_exists(opened_save_folder.path_join(_LIBRARY_PATH)):
		return
	var file_access := FileAccess.open(opened_save_folder.path_join(_LIBRARY_PATH), FileAccess.READ)
	var json_string:= FileAccess.get_file_as_string(opened_save_folder.path_join(_LIBRARY_PATH))
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	library = json.data
	Main.on_library_reload()

static func save_settings() -> void:
	SettingsHandler.export()
	var json_string := JSON.stringify(settings, "\t")
	var file_access := FileAccess.open(opened_save_folder.path_join(_SETTINGS_PATH), FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()

static func load_settings() -> void:
	if not FileAccess.file_exists(opened_save_folder.path_join(_SETTINGS_PATH)):
		save_settings()
		SettingsHandler.initialize()
		return
	var file_access := FileAccess.open(opened_save_folder.path_join(_SETTINGS_PATH), FileAccess.READ)
	var json_string:= FileAccess.get_file_as_string(opened_save_folder.path_join(_SETTINGS_PATH))
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	settings = json.data
	SettingsHandler.initialize()
	Main.on_settings_reload()
	Main.on_dict_reload()

# TMFDS DICT.save structure:
#{
#    "wordDict": {
#        "keys": [
#            -1,
#        ],
#        "values": [
#            "-",
#        ]
#    },
#    "descDict": {
#        "keys": [
#            -1,
#        ],
#        "values": [
#            {
#                "desc": "negative sign",
#                "formatMode": 0,
#                "formatModeAfter": 0,
#                "breakOnDouble": false
#            },
#        ]
#    },
#    "id": 1,
#    "beforeUserDefaultMode": 1,
#    "afterUserDefaultMode": 1
#}
# formatting codes:
# 0: no space
# 1: space
# 2: new line
# 3: double new line

static func load_dict(path: String = "") -> bool:
	if path.is_empty():
		path = opened_save_folder.path_join(_DICT_FOLDER).path_join(_current_dictionary_filename)
		var dir := DirAccess.open(opened_save_folder)
		if (
			dir.file_exists("DICTIONARY-1.save")
			and path != opened_save_folder.path_join("DICTIONARY-1.save")
		):
			load_dict(opened_save_folder.path_join("DICTIONARY-1.save"))
			save_dict()
			dir.remove("DICTIONARY-1.save")
			return true
	var file_access := FileAccess.open(path, FileAccess.READ)
	if not FileAccess.file_exists(path):
		save_dict()
		Main.on_dict_reload()
		open_save_location()
		var orig_json_string := FileAccess.get_file_as_string(path)
		var tries: int = 0
		DictionaryHandler.bad_dict = true
		while (
			(not FileAccess.file_exists(path)) or
			orig_json_string == FileAccess.get_file_as_string(path)
		):
			if tries > 60:
				return false
			await Main.instance.get_tree().create_timer(1).timeout
			tries += 1
		load_dict()
		return false
	var json_string:= FileAccess.get_file_as_string(path)
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return false
	
	var old_dict := dict
	dict = json.data
	DictionaryHandler.initialize()
	DictionaryHandler.sort_dictionary()
	eval_bad_dict()
	if DictionaryHandler.bad_dict:
		dict = old_dict
		DictionaryHandler.initialize()
		DictionaryHandler.sort_dictionary()
		eval_bad_dict()
		return false

	Main.on_dict_reload()
	return true

static func eval_bad_dict() -> void:
	DictionaryHandler.bad_dict = dict.is_empty() or DictionaryHandler.word_keys.is_empty() or DictionaryHandler.word_names.is_empty()

static func save_dict() -> void:
	DictionaryHandler.export()
	var json_string := JSON.stringify(dict, "\t")
	var file_access := FileAccess.open(opened_save_folder.path_join(_DICT_FOLDER.path_join(_current_dictionary_filename)), FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()
