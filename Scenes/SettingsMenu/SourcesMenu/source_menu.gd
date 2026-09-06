extends Control
class_name SourcesMenu

static var instance: SourcesMenu

@onready var wss_list: VBoxContainer = $VBoxContainer/HBoxContainer/WSSPanel/ScrollContainer/VBoxContainer
@onready var dc_list: VBoxContainer = $VBoxContainer/HBoxContainer/DictPanel/ScrollContainer/VBoxContainer

var wss_entry = preload("res://Scenes/SettingsMenu/SourcesMenu/websocket_entry.tscn")
var dc_entry = preload("res://Scenes/SettingsMenu/SourcesMenu/dict_change_entry.tscn")

func _enter_tree():
	instance = self

func _ready():
	Main.instance.post_load.connect(refresh)
	_refresh_dicts()

static func refresh_files():
	instance._refresh_dicts()

func refresh():
	if not is_node_ready():
		await ready
	_refresh_wss()
	_refresh_dicts()

func _on_add_wss_pressed():
	var obj: WSSEntry = wss_entry.instantiate()
	obj.address = ""
	wss_list.add_child(obj)
	obj.edit.grab_focus()
	obj.edit.select_all()
	SettingsHandler.add_wss(Main.DSCR_URL)
	SettingsHandler.save()

func _on_directory_button_pressed():
	SaveSystem.change_directory_location()

var ticker: int = 0
func _physics_process(_delta):
	if not is_visible_in_tree():
		return
	if ticker > 256:
		for c: DictChangeEntry in dc_list.get_children():
			if c.edit.has_focus():
				return
		_refresh_dicts()
		ticker = -1
	ticker += 1

func _refresh_wss():
	for c in wss_list.get_children():
		c.queue_free()
	for c in SettingsHandler.websocket_addresses:
		var obj: WSSEntry = wss_entry.instantiate()
		obj.address = c
		wss_list.add_child(obj)

func _refresh_dicts():
	var dicts: PackedStringArray = SaveSystem.get_all_dict_names()
	for c in dc_list.get_children():
		c.queue_free()
	for d in dicts:
		var obj: DictChangeEntry = dc_entry.instantiate()
		obj.dict_name = d
		dc_list.add_child(obj)

func _on_add_dict_pressed():
	var obj: DictChangeEntry = dc_entry.instantiate()
	var nam: String = SaveSystem.get_valid_dict_name("DICTIONARY-1.save")
	obj.dict_name = nam
	dc_list.add_child(obj)
	obj.edit.grab_focus()
	obj.edit.select_all()
	SaveSystem.create_skeleton_dict_file(nam)
