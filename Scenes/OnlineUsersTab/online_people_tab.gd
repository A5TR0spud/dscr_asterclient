extends Container

func _ready():
	Main.instance.ReloadDict.connect(Refresh)
	Main.instance.ConnectedUserChange.connect(Reload)

var entry = preload("res://Scenes/OnlineUsersTab/callsign_entry.tscn")

@onready var List: FlowContainer = $ScrollContainer/Margins/List
@onready var Header: Label = $Label

func Reload() -> void:
	Refresh()
	for i in List.get_children():
		i.queue_free()
	for i in Main.instance.ConnectedUsers:
		var inst: CallsignEntry = entry.instantiate()
		inst.CS = i
		List.add_child(inst)

func Refresh() -> void:
	Header.text = DictionaryHandler.Signals2Words([-130, -23, -4, Main.instance.ConnectedUsers.size()])
