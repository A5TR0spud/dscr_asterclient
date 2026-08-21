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

const _DICT_PATH: String = "DICTIONARY-1.save"
const _MACRO_PATH: String = "macro.json"
const _SETTINGS_PATH: String = "settings.json"
const _NICKNAMES_PATH: String = "nicknames.json"
const DIRECTORY_PATH: String = "user://directory.txt"
static var directory: String = ProjectSettings.globalize_path("user://")
static var dict_path: String:
	get:
		return directory.path_join(_DICT_PATH)
static var macro_path: String:
	get:
		return directory.path_join(_MACRO_PATH)
static var settings_path: String:
	get:
		return directory.path_join(_SETTINGS_PATH)
static var nicknames_path: String:
	get:
		return directory.path_join(_NICKNAMES_PATH)

static func load() -> void:
	load_directory()
	load_dict()
	load_settings()
	load_nicknames()

static func save_directory() -> void:
	var file_access := FileAccess.open(DIRECTORY_PATH, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(directory)
	file_access.close()

static func load_directory() -> void:
	if not FileAccess.file_exists(DIRECTORY_PATH):
		save_directory()
		return
	var file_access := FileAccess.open(DIRECTORY_PATH, FileAccess.READ)
	var strig := FileAccess.get_file_as_string(DIRECTORY_PATH)
	file_access.close()
	directory = strig

static func open_save_location() -> void:
	OS.shell_show_in_file_manager(dict_path)

static func open_directory_location() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(DIRECTORY_PATH))

static func save_nicknames() -> void:
	var json_string := JSON.stringify(nicknames, "\t")
	var file_access := FileAccess.open(nicknames_path, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()

static func load_nicknames() -> void:
	if not FileAccess.file_exists(nicknames_path):
		save_nicknames()
		return
	var file_access := FileAccess.open(nicknames_path, FileAccess.READ)
	var json_string:= FileAccess.get_file_as_string(nicknames_path)
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	nicknames = json.data
	Main.on_nicknames_reload()

static func save_settings() -> void:
	SettingsHandler.export()
	var json_string := JSON.stringify(settings, "\t")
	var file_access := FileAccess.open(settings_path, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()

static func load_settings() -> void:
	if not FileAccess.file_exists(settings_path):
		save_settings()
		SettingsHandler.initialize()
		return
	var file_access := FileAccess.open(settings_path, FileAccess.READ)
	var json_string:= FileAccess.get_file_as_string(settings_path)
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

static func load_dict() -> void:
	var file_access := FileAccess.open(dict_path, FileAccess.READ)
	if not FileAccess.file_exists(dict_path):
		save_dict()
		Main.on_dict_reload()
		open_save_location()
		var orig_json_string := FileAccess.get_file_as_string(dict_path)
		var tries: int = 0
		DictionaryHandler.bad_dict = true
		while (
			(not FileAccess.file_exists(dict_path)) or
			orig_json_string == FileAccess.get_file_as_string(dict_path)
		):
			if tries > 60:
				return
			await Main.instance.get_tree().create_timer(1).timeout
			tries += 1
		load_dict()
		return
	var json_string:= FileAccess.get_file_as_string(dict_path)
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	dict = json.data
	DictionaryHandler.initialize()
	DictionaryHandler.sort_dictionary()
	eval_bad_dict()
	Main.on_dict_reload()

static func eval_bad_dict() -> void:
	DictionaryHandler.bad_dict = dict.is_empty() or DictionaryHandler.word_keys.is_empty() or DictionaryHandler.word_names.is_empty()

static func save_dict() -> void:
	DictionaryHandler.export()
	var json_string := JSON.stringify(dict, "\t")
	var file_access := FileAccess.open(dict_path, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()
