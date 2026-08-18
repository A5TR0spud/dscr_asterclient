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

const DICT_PATH : String = "user://DICTIONARY-1.save"
const MACRO_PATH : String = "user://macro.json"
const SETTINGS_PATH : String = "user://settings.json"

static func open_save_location() -> void:
	OS.shell_show_in_file_manager(ProjectSettings.globalize_path(DICT_PATH))

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

static func load() -> void:
	load_dict()
	load_settings()

static func save_settings() -> void:
	SettingsHandler.export()
	var json_string := JSON.stringify(settings, "\t")
	var file_access := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()

static func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		save_settings()
		SettingsHandler.initialize()
		return
	var file_access := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	var json_string:= FileAccess.get_file_as_string(SETTINGS_PATH)
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	settings = json.data
	SettingsHandler.initialize()
	Main.on_settings_reload()

static func load_dict() -> void:
	var file_access := FileAccess.open(DICT_PATH, FileAccess.READ)
	if not FileAccess.file_exists(DICT_PATH):
		save_dict()
		Main.on_dict_reload()
		open_save_location()
		var orig_json_string := FileAccess.get_file_as_string(DICT_PATH)
		var tries: int = 0
		while (
			(not FileAccess.file_exists(DICT_PATH)) or
			orig_json_string == FileAccess.get_file_as_string(DICT_PATH)
		):
			if tries > 60:
				return
			await Main.instance.get_tree().create_timer(1).timeout
			tries += 1
		load_dict()
		return
	var json_string:= FileAccess.get_file_as_string(DICT_PATH)
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	dict = json.data
	DictionaryHandler.initialize()
	DictionaryHandler.sort_dictionary()
	Main.on_dict_reload()

static func save_dict() -> void:
	DictionaryHandler.export()
	var json_string := JSON.stringify(dict, "\t")
	var file_access := FileAccess.open(DICT_PATH, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()
