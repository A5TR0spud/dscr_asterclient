extends Node
## Handles translation of properties for the parent node
class_name LocaleNode

## Map of property names to translation keys
@export var translations: Dictionary[StringName, String]
@export var isPluralizable: bool

func _ready():
	Main.instance.localization_reload.connect(refresh)
	refresh()

signal locale_reloaded

	
func refresh():
	locale_reloaded.emit()
	var parent: Node = get_parent()
	if not parent:
		return
	if isPluralizable:
		for m in translations.keys():
			parent.set(m, Localizer.translate_plural(translations[m], parent.value))
	else:
		for m in translations.keys():
			parent.set(m, Localizer.translate(translations[m]))
