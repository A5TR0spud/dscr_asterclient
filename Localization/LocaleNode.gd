extends Node
## Handles translation of properties for the parent node
class_name LocaleNode

## Map of property names to translation keys
@export var translations: Dictionary[StringName, String]

func _ready():
	Main.instance.reload_dict.connect(refresh.bind(true))
	Main.instance.localization_reload.connect(refresh)
	refresh()

signal locale_reloaded

func refresh(from_dict_reload: bool = false):
	if from_dict_reload and TranslationServer.get_locale() != "m0":
		return
	locale_reloaded.emit()
	var parent: Node = get_parent()
	if not parent:
		return
	for m in translations.keys():
		parent.set(m, Localizer.translate(translations[m]))
