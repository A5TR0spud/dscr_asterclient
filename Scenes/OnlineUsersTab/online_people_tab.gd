extends Container

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.connected_user_change.connect(reload)

var entry = preload("res://Scenes/OnlineUsersTab/callsign_entry.tscn")

@onready var list_node: VBoxContainer = $ScrollContainer/Margins/List
@onready var header_node: Label = $Label

func delete_callsign_entry(n: Node):
	n.queue_free()
	list_node.move_child(n, list_node.get_child_count())

func reload() -> void:
	refresh()
	var known_callsigns: Array[int] = []
	for i: CallsignEntry in list_node.get_children():
		if i.callsign not in Main.instance.connected_users:
			print("User removed: ", i.callsign, " : ", Main.base_10_to_callsign(i.callsign))
			if i.name_node.has_focus():
				if not i.name_node.focus_exited.is_connected(reload):
					i.name_node.focus_exited.connect(reload)
			else:
				delete_callsign_entry(i)
				continue
		known_callsigns.append(i.callsign)
	var idx: int = 0
	for i in Main.instance.connected_users:
		if i in known_callsigns:
			idx += 1
			continue
		print("User added: ", i, " : ", Main.base_10_to_callsign(i))
		var inst: CallsignEntry = entry.instantiate()
		inst.callsign = i
		list_node.add_child(inst)
		list_node.move_child(inst, idx)
		idx += 1

func refresh() -> void:
	header_node.text = DictionaryHandler.signals_to_words([-130, -23, -4, Main.instance.connected_users.size()])
