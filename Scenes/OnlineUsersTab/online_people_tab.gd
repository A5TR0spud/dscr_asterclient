extends Container

class_name ActiveUsersTab

static var instance: ActiveUsersTab

func _ready():
	instance = self
	#Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh)
	Main.instance.connected_user_change.connect(reload)
	Main.instance.reload_nicknames.connect(reload_known)

var entry = preload("res://Scenes/OnlineUsersTab/callsign_entry.tscn")

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var online_list: VBoxContainer = $ScrollContainer/List/OnlineLabel/Online
@onready var known_list: VBoxContainer = $ScrollContainer/List/KnownLabel/Known
@onready var header_node: Label = $Label
@onready var known_label: Control = $ScrollContainer/List/KnownLabel
@onready var online_drop: FoldableContainer = $ScrollContainer/List/OnlineLabel
@onready var known_drop: FoldableContainer = $ScrollContainer/List/KnownLabel

func _reload_helper(container: VBoxContainer, new_list: Array[int]):
	var already_present: Array[int] = []
	for i: CallsignEntry in container.get_children():
		if i.callsign not in new_list:
			if i.name_node.has_focus():
				if not i.name_node.focus_exited.is_connected(_reload_helper.bind(container, new_list)):
					i.name_node.focus_exited.connect(_reload_helper.bind(container, new_list))
			else:
				i.queue_free()
				i.move_to_front.call_deferred()
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
	header_node.text = Localizer.translate("USERS_HEADER", Main.instance.connected_users.size())

static func select_callsign(cs: int) -> void:
	instance._select_callsign(cs)

func _select_callsign(cs: int) -> void:
	if cs in Main.instance.connected_users:
		online_drop.expand()
		_select_callsign_in(online_list, cs)
		return
	if cs in NicknamesHandler.get_all_nicknames():
		known_drop.expand()
		_select_callsign_in(known_list, cs)
		return
	var arr: Array[int] = NicknamesHandler.get_all_nicknames()
	arr.append(cs)
	arr.sort()
	known_label.visible = arr.size() > 0
	_reload_helper(known_list, arr)
	known_drop.expand()
	_select_callsign_in(known_list, cs)

func _select_callsign_in(container: VBoxContainer, cs: int) -> void:
	await get_tree().physics_frame
	for c: CallsignEntry in container.get_children():
		if c.callsign == cs:
			c.name_node.grab_focus()
			c.name_node.caret_column = c.name_node.text.length()
			scroll.ensure_control_visible(c)
			return
