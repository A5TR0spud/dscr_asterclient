extends PanelContainer
class_name LocaleMenu

static var instance: LocaleMenu
const VALID_LANGUAGES: PackedStringArray = ["en", "pl"]
@onready var m0: Button = $CenterContainer/VBoxContainer/PanelContainer/VBoxContainer/m0

func _enter_tree():
	instance = self

func _ready():
	Main.instance.reload_settings.connect(refresh)

func refresh():
	m0.button_pressed = SettingsHandler.use_m0_ui

static func open():
	instance.show()

func _select(code: String):
	SettingsHandler.validate_and_set_language(code)

func _on_close_pressed():
	instance.hide()

func _on_m_0_toggled(toggled_on: bool):
	SettingsHandler.use_m0_ui = toggled_on
	SettingsHandler.save()
	Main.on_localization_reload()

func _on_en_pressed():
	_select("en")

func _on_pl_pressed():
	_select("pl")
