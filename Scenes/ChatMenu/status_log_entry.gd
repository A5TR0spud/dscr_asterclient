extends ChatEntry
class_name StatusLogEntry

@onready var TI: Label = $Header/Timeago
@onready var MG: RichTextLabel = $Body/Corpus/Message
@onready var TAB: VSeparator = $Body/MessageIndent
@onready var ETC: Button = $Body/Corpus/ContextButtons/EtcButton

func Ready():
	Main.instance.ReloadDict.connect(Refresh)

func _physics_process(_delta):
	CalcTime()
	TI.text = TimeAgo

func Refresh():
	pass

func SetMessageText(newText: String):
	MG.text = newText

func _on_delete_button_pressed():
	queue_free()

func _on_etc_button_toggled(toggled_on):
	Collapsed = not toggled_on

func _on_set_etc_visibility(visibility: bool):
	ETC.visible = visibility
