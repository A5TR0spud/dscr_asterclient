extends Container

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.connected_user_change.connect(reload)
	Main.instance.reload_nicknames.connect(reload_known)

var entry = preload("res://Scenes/OnlineUsersTab/callsign_entry.tscn")

@onready var online_list: VBoxContainer = $ScrollContainer/Margins/List/OnlineLabel/Online
@onready var known_list: VBoxContainer = $ScrollContainer/Margins/List/KnownLabel/Known
@onready var header_node: Label = $Label
@onready var known_label: Control = $ScrollContainer/Margins/List/KnownLabel

func _reload_helper(container: VBoxContainer, new_list: Array[int]):
	var already_present: Array[int] = []
	for i: CallsignEntry in container.get_children():
		if i.callsign not in new_list:
			if i.name_node.has_focus():
				if not i.name_node.focus_exited.is_connected(_reload_helper.bind(container, new_list)):
					i.name_node.focus_exited.connect(_reload_helper.bind(container, new_list))
			else:
				i.queue_free()
				i.move_to_front()
				continue
		already_present.append(i.callsign)
	var idx: int = 0
	for i in new_list:
		if i in already_present:
			idx += 1
			continue
		var inst: CallsignEntry = entry.instantiate()
		inst.callsign = i
		container.add_child(inst)
		container.move_child(inst, idx)
		idx += 1

func reload_known() -> void:
	var arr: Array[int] = NicknamesHandler.get_all_nicknames()
	arr.sort()
	known_label.visible = arr.size() > 0
	_reload_helper(known_list, arr)

func reload() -> void:
	refresh()
	_reload_helper(online_list, Main.instance.connected_users)

func refresh() -> void:
	header_node.text = DictionaryHandler.signals_to_words([-130, -23, -4, Main.instance.connected_users.size()])
