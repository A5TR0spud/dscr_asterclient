extends Container

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.connected_user_change.connect(reload)

var entry = preload("res://Scenes/OnlineUsersTab/callsign_entry.tscn")

@onready var list_node: VBoxContainer = $ScrollContainer/Margins/List
@onready var header_node: Label = $Label

func reload() -> void:
	refresh()
	var known_callsigns: Array[int] = []
	for i: CallsignEntry in list_node.get_children():
		if i.callsign not in Main.instance.connected_users:
			i.queue_free()
		else:
			known_callsigns.append(i.callsign)
	for i in Main.instance.connected_users:
		if i in known_callsigns:
			continue
		var inst: CallsignEntry = entry.instantiate()
		inst.callsign = i
		list_node.add_child(inst)

func refresh() -> void:
	header_node.text = DictionaryHandler.signals_to_words([-130, -23, -4, Main.instance.connected_users.size()])
