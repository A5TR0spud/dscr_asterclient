extends Container

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.connected_user_change.connect(reload)

var entry = preload("res://Scenes/OnlineUsersTab/callsign_entry.tscn")

@onready var list_node: FlowContainer = $ScrollContainer/Margins/List
@onready var header_node: Label = $Label

func reload() -> void:
	refresh()
	for i in list_node.get_children():
		i.queue_free()
	for i in Main.instance.connected_users:
		var inst: CallsignEntry = entry.instantiate()
		inst.callsign = i
		list_node.add_child(inst)

func refresh() -> void:
	header_node.text = DictionaryHandler.signals_to_words([-130, -23, -4, Main.instance.connected_users.size()])
