extends VBoxContainer

func _ready() -> void:
	Main.instance.ReloadSettings.connect(Refresh)

@onready var Formatting: SettingEntry = $ScrollContainer/MarginContainer/Options/Formatting
@onready var Trunc: SpinBox = $ScrollContainer/MarginContainer/Options/TruncMargin/TruncHbox/TruncationSpinner

func Refresh() -> void:
	Formatting.State = SettingsHandler.DoFormatting
	Trunc.value = SettingsHandler.TruncateMessageSize

func Save() -> void:
	SettingsHandler.Save()
	Main.OnSettingsReload()

func _on_formatting_set(new_value):
	SettingsHandler.DoFormatting = new_value
	Save()

var count: int = 0
func _physics_process(_delta):
	if count >= 5:
		if SettingsHandler.TruncateMessageSize != roundi(Trunc.value):
			SettingsHandler.TruncateMessageSize = roundi(Trunc.value)
			Save()
		count = -1
	count += 1
