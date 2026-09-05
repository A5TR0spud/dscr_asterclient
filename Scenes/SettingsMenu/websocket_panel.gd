extends FoldableContainer

@onready var list: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer

var wss_entry = preload("res://Scenes/SettingsMenu/websocket_entry.tscn")

func _try_address():
	Main.reconnect_or_change_url("address_edit.text")

func _ready():
	Main.instance.post_load.connect(refresh)

func refresh():
	for c in SettingsHandler.websocket_addresses:
		var obj: WSSEntry = wss_entry.instantiate()
		obj.address = c
		list.add_child(obj)

func _on_add_wss_pressed():
	var obj: WSSEntry = wss_entry.instantiate()
	obj.address = ""
	list.add_child(obj)
	SettingsHandler.add_wss(Main.DSCR_URL)
	SettingsHandler.save()
