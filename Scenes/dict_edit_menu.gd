extends CenterContainer
class_name DictEditMenu

static var instance: DictEditMenu

func _enter_tree():
	instance = self

@export var CURRENT_SIGNAL: int = 0:
	set(value):
		CURRENT_SIGNAL = min(value, -1)
		Reload()

@onready var NameLabel: Label = $PanelContainer/DictEditMainframe/SignalNameEdit/NameLabel
@onready var BefLabel: OptionButton = $PanelContainer/DictEditMainframe/BeforeAndAfterFormat/BeforeOption
@onready var BAClearLabel: Label = $PanelContainer/DictEditMainframe/BeforeAndAfterFormat/FormatClarity
@onready var AftLabel: OptionButton = $PanelContainer/DictEditMainframe/BeforeAndAfterFormat/AfterOption
@onready var BrkButton: BoolButton = $PanelContainer/DictEditMainframe/BreakSentence/BreakOnDouble

@onready var NameEdit: LineEdit = $PanelContainer/DictEditMainframe/SignalNameEdit/NameLineEdit
@onready var DescEdit: TextEdit = $PanelContainer/DictEditMainframe/NotesEdit

func _ready():
	Main.instance.ReloadDict.connect(Refresh)
	hide()

func Save() -> void:
	DictionaryHandler.ApplySignalName(CURRENT_SIGNAL, NameEdit.text)
	NameLabel.text = DictionaryHandler.GetOrDefaultSignalName(CURRENT_SIGNAL)
	DictionaryHandler.ApplySignalDesc(CURRENT_SIGNAL, {
		DictionaryHandler.descKey: DescEdit.text,
		DictionaryHandler.beforeKey: BefLabel.selected,
		DictionaryHandler.afterKey: AftLabel.selected,
		DictionaryHandler.breakKey: BrkButton.IsOn
	})
	SaveSystem.SaveDict()
	Main.OnDictReload()

func Reload() -> void:
	var desc: Dictionary = DictionaryHandler.GetOrDefaultSignalDesc(CURRENT_SIGNAL)
	NameLabel.text = DictionaryHandler.Signals2Words([-42, -14, -1, absi(CURRENT_SIGNAL), -15, -4])
	BAClearLabel.text = DictionaryHandler.Signals2Words([-122, CURRENT_SIGNAL, -122])
	NameEdit.text = DictionaryHandler.GetOrDefaultSignalName(CURRENT_SIGNAL)
	DescEdit.text = desc[DictionaryHandler.descKey]
	BefLabel.select(int(desc[DictionaryHandler.beforeKey]))
	AftLabel.select(int(desc[DictionaryHandler.afterKey]))
	BrkButton.IsOn = desc[DictionaryHandler.breakKey]

func Refresh():
	Reload()
	BefLabel.set("popup/item_0/text", DictionaryHandler.Signals2Words([-111]))
	BefLabel.set("popup/item_1/text", DictionaryHandler.Signals2Words([1, -190]))
	BefLabel.set("popup/item_2/text", DictionaryHandler.Signals2Words([1, -108, -190]))
	BefLabel.set("popup/item_3/text", DictionaryHandler.Signals2Words([2, -108, -190]))
	AftLabel.set("popup/item_0/text", DictionaryHandler.Signals2Words([-111]))
	AftLabel.set("popup/item_1/text", DictionaryHandler.Signals2Words([1, -190]))
	AftLabel.set("popup/item_2/text", DictionaryHandler.Signals2Words([1, -108, -190]))
	AftLabel.set("popup/item_3/text", DictionaryHandler.Signals2Words([2, -108, -190]))

func _input(event: InputEvent):
	if event.is_action_pressed("ui_close_dialog"):
		hide()

func _on_submit_button_pressed():
	Save()
	#hide()

func _on_cancel_button_pressed():
	Reload()

func _on_close_button_pressed():
	hide()

func _on_delete_button_pressed():
	DictionaryHandler.ForgetSignal(CURRENT_SIGNAL)
	Main.OnDictReload()
	hide()

func _on_name_line_edit_text_submitted(_new_text):
	Save()

func _on_name_line_edit_text_changed(new_text):
	var col := NameEdit.caret_column
	NameEdit.text = DictionaryHandler.FilterNameInput(new_text)
	NameEdit.caret_column = col
