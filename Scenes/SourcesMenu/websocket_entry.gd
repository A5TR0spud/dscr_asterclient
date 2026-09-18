extends VBoxContainer
class_name WSSEntry

var address: String = ""

@onready var edit: LineEdit = $LineEdit

func _ready():
	edit.placeholder_text = Main.DSCR_URL
	refresh()

func refresh():
	if address.is_empty():
		address = Main.DSCR_URL
	edit.text = address

func _on_confirmation_button_confirmed():
	SettingsHandler.delete_wss(address)
	queue_free()

func _on_connect_button_pressed():
	Main.reconnect_or_change_url(address)

func _on_line_edit_text_submitted(new_text: String):
	SettingsHandler.change_wss(address, new_text)
	address = new_text

func _on_line_edit_focus_exited():
	refresh()
