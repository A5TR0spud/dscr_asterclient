extends GridContainer
class_name PeriodicTable

@onready var tooltip: PanelContainer = $"../PopupPanel"
@onready var tip_name: Label = $"../PopupPanel/VBoxContainer/Name"
@onready var tip_proton: Label = $"../PopupPanel/VBoxContainer/ProtonLong"
@onready var tip_metallicity: Label = $"../PopupPanel/VBoxContainer/Metallicity"
@onready var tip_unstable: Label = $"../PopupPanel/VBoxContainer/Radioactive"
@onready var tip_noble: Label = $"../PopupPanel/VBoxContainer/Nobility"
@onready var tip_diatomic: Label = $"../PopupPanel/VBoxContainer/Diatomic"
@onready var tip_phase: Label = $"../PopupPanel/VBoxContainer/Phase"

var _current_element: int = 0

signal focus(elem: int)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		get_viewport().update_mouse_cursor_state.call_deferred()

func on_hover_start(elem: ElementCell):
	var element: int = elem.element
	var r: Rect2 = elem.get_rect()
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
	elif m == ElementCell.Metallicity.NONMETAL:
		key += "NONMETAL"
		tip_metallicity.modulate = Color(1.0, 0.6, 0.6)
	tip_metallicity.visible = m != ElementCell.Metallicity.UNKNOWN
	tip_metallicity.text = Localizer.translate(key)
	key = "REFERENCE_PD_STP_"
	var n: ElementCell.Phase = ElementCell.phase_at_stp(element)
	if n == ElementCell.Phase.SOLID:
		key += "SOLID"
		tip_phase.modulate = Color(0.537, 0.59, 0.538, 1.0)
	elif n == ElementCell.Phase.LIQUID:
		key += "LIQUID"
		tip_phase.modulate = Color(0.49, 0.748, 0.96, 1.0)
	elif n == ElementCell.Phase.GAS:
		key += "GAS"
		tip_phase.modulate = Color(1.0, 0.813, 0.65, 1.0)
	tip_phase.visible = n != ElementCell.Phase.UNKNOWN
	tip_phase.text = Localizer.translate(key)
	
	tip_unstable.visible = ElementCell.no_stable_isotopes(element)
	tip_noble.visible = ElementCell.noble_gas(element)
	tip_diatomic.visible = ElementCell.diatomic(element)
	tooltip.offset_transform_position = Vector2(
		r.position.x + r.size.x - 2, r.position.y
	)
	tooltip.reset_size()
	var screen_bottom: float = size.y
	var tip_bottom: float = tooltip.offset_transform_position.y + tooltip.size.y
	if tip_bottom > screen_bottom:
		tooltip.offset_transform_position.y -= tip_bottom - screen_bottom
	var screen_right: float = size.x
	var tip_right: float = tooltip.offset_transform_position.x + tooltip.size.x
	if tip_right > screen_right:
		tooltip.offset_transform_position.x = r.position.x - tooltip.size.x + 2
	_current_element = element
	tooltip.show()
	focus.emit(element)

func on_hover_end(elem: ElementCell):
	if _current_element == elem.element:
		tooltip.hide()
		focus.emit(-1)
