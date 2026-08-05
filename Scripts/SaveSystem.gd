class_name SaveSystem

static var Dict: Dictionary = {
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

const DICT_PATH : String = "user://DICTIONARY-1.save"
const MACRO_PATH : String = "user://macro.json"
const SETTINGS_PATH : String = "user://settings.json"

static func OpenSaveLocation() -> void:
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

static func LoadDict() -> void:
	var file_access := FileAccess.open(DICT_PATH, FileAccess.READ)
	if not FileAccess.file_exists(DICT_PATH):
		SaveDict()
		Main.OnDictReload()
		OpenSaveLocation()
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
		LoadDict()
		return
	var json_string:= FileAccess.get_file_as_string(DICT_PATH)
	file_access.close()
	var json := JSON.new()
	var error := json.parse(json_string)
	if error:
		print("JSON Parse Error: ", error)
		return
	Dict = json.data
	DictionaryHandler.Initialize()
	DictionaryHandler.SortDictionary()
	Main.OnDictReload()

static func SaveDict() -> void:
	DictionaryHandler.Export()
	var json_string := JSON.stringify(Dict, "\t")
	var file_access := FileAccess.open(DICT_PATH, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	file_access.store_string(json_string)
	file_access.close()
