extends PanelContainer
class_name LocaleMenu

static var instance: LocaleMenu

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
