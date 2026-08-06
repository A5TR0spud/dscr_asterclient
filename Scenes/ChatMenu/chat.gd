extends VBoxContainer
class_name Chat

static var instance: Chat
static var Trx = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
@onready var ChatBody: VBoxContainer = $MarginContainer/ScrollContainer/MarginContainer/ChatDisplay

func _enter_tree():
	instance = self

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		DictEditMenu.instance.hide()

static func NewTransmission(incoming: PackedStringArray) -> void:
	var newMessage: TransEntry = Trx.instantiate()
	newMessage.Timestamp = Time.get_ticks_msec()
	newMessage.Sender = incoming[0].to_int()
	newMessage.Trans = incoming[1].to_int()
	var o: Array[int] = []
	for s in incoming.slice(2):
		o.append(s.to_int())
	newMessage.Message = o
	instance.ChatBody.add_child(newMessage)
