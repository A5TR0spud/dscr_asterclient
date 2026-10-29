extends Node
## Handles translation of properties for the parent node
class_name LocaleNode

## Map of property names to translation keys
@export var translations: Dictionary[StringName, String]

func _ready():
	Main.instance.localization_reload.connect(refresh)
	var parent: Node = get_parent()
	if parent is SpinBox:
		parent.value_changed.connect(refresh_on_value_changed)
	refresh()

signal locale_reloaded

func refresh_on_value_changed(val):
	refresh()
	
func refresh():
	locale_reloaded.emit()
	var parent: Node = get_parent()
	if not parent:
		return
	if parent is SpinBox:
		for m in translations.keys():
			parent.set(m, Localizer.translate_plural(translations[m], parent.value))
	else:
		for m in translations.keys():
			parent.set(m, Localizer.translate(translations[m]))
