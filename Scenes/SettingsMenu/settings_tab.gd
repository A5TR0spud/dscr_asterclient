extends VBoxContainer

func _ready() -> void:
	Main.instance.ReloadSettings.connect(Refresh)

@onready var Formatting: SettingEntry = $ScrollContainer/MarginContainer/Options/Formatting
@onready var ImageVis: SettingEntry = $ScrollContainer/MarginContainer/Options/ImageVis
@onready var Trunc: SpinBox = $ScrollContainer/MarginContainer/Options/TruncMargin/TruncHbox/TruncationSpinner
@onready var Fon: SpinBox = $ScrollContainer/MarginContainer/Options/FontMargin/FontHbox/FontSpinner

func Refresh() -> void:
	Formatting.State = SettingsHandler.DoFormatting
	ImageVis.State = SettingsHandler.ImageDefault
	Trunc.value = SettingsHandler.TruncateMessageSize
	Fon.value = SettingsHandler.FontSize

func Save() -> void:
	SettingsHandler.Save()
	Main.OnSettingsReload()

func _on_formatting_set(new_value):
	SettingsHandler.DoFormatting = new_value
	Save()

func _on_image_vis_set(new_value):
	SettingsHandler.ImageDefault = new_value
	Save()

var count: int = 0
func _physics_process(_delta):
	if count >= 5:
		if SettingsHandler.TruncateMessageSize != roundi(Trunc.value):
			SettingsHandler.TruncateMessageSize = roundi(Trunc.value)
			Save()
		count = -1
	count += 1

func _on_font_spinner_value_changed(value):
	SettingsHandler.FontSize = value
	Save()
