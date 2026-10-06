extends PanelContainer
class_name LocaleMenu

static var instance: LocaleMenu
const VALID_LANGUAGES: PackedStringArray = ["m0", "en", "pl"]

func _enter_tree():
	instance = self

static func open():
	instance.show()

func _select(code: String):
	SettingsHandler.validate_and_set_language(code)
	instance.hide()

func _on_m_0_pressed():
	_select("m0")

func _on_en_pressed():
	_select("en")
	
func _on_pl_pressed():
	_select("pl")
