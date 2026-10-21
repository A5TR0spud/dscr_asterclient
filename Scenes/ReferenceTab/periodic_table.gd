extends GridContainer
class_name PeriodicTable

@onready var tooltip: PopupPanel = $PopupPanel
@onready var tip_name: Label = $PopupPanel/VBoxContainer/Name
@onready var tip_proton: Label = $PopupPanel/VBoxContainer/ProtonLong
@onready var tip_metallicity: Label = $PopupPanel/VBoxContainer/Metallicity

var _current_element: int = 0

signal focus(elem: int)

func on_hover_start(elem: ElementCell):
	tooltip.hide()
	var element: int = elem.element
	var r: Rect2 = elem.get_global_rect()
	tip_name.text = elem.name_label.text
	tip_proton.text = Localizer.translate_plural("REFERENCE_PD_PROTON", element, element)
	var key: String = "REFERENCE_PD_"
	var m: ElementCell.Metallicity = ElementCell.get_metallicity(element)
	if m == ElementCell.Metallicity.METAL:
		key += "METAL"
		tip_metallicity.modulate = Color(0.6, 0.6, 1.0)
	elif m == ElementCell.Metallicity.METALLOID:
		key += "METALLOID"
		tip_metallicity.modulate = Color(0.6, 0.8, 0.8)
	else:
		key += "NONMETAL"
		tip_metallicity.modulate = Color(1.0, 0.6, 0.6)
	tip_metallicity.text = Localizer.translate(key)
	@warning_ignore("narrowing_conversion")
	tooltip.popup.call_deferred(Rect2i(
		r.position.x + r.size.x - 2, r.position.y, 0, 0
	))
	_current_element = element
	focus.emit(element)

func on_hover_end(elem: ElementCell):
	if _current_element == elem.element:
		tooltip.hide()
		focus.emit(-1)
