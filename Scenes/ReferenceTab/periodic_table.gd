extends GridContainer
class_name PeriodicTable

@onready var tooltip: PanelContainer = $"../PopupPanel"
@onready var tip_name: Label = $"../PopupPanel/VBoxContainer/Name"
@onready var tip_proton: Label = $"../PopupPanel/VBoxContainer/ProtonLong"
@onready var tip_unstable: Control = $"../PopupPanel/VBoxContainer/Decays"
@onready var tip_noble: Control = $"../PopupPanel/VBoxContainer/Noble"
@onready var tip_diatomic: Control = $"../PopupPanel/VBoxContainer/Diatomic"
@onready var tip_solid: Control = $"../PopupPanel/VBoxContainer/Solid"
@onready var tip_liquid: Control = $"../PopupPanel/VBoxContainer/Liquid"
@onready var tip_gas: Control = $"../PopupPanel/VBoxContainer/Gas"
@onready var tip_metal: Control = $"../PopupPanel/VBoxContainer/Metal"
@onready var tip_metalloid: Control = $"../PopupPanel/VBoxContainer/Metalloid"
@onready var tip_nonmetal: Control = $"../PopupPanel/VBoxContainer/Nonmetal"

var _current_element: int = 0

signal focus(elem: int)

func _ready():
	tooltip.hide()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		get_viewport().update_mouse_cursor_state.call_deferred()

func on_hover_start(elem: ElementCell):
	var element: int = elem.element
	var r: Rect2 = elem.get_rect()
	tip_name.text = elem.name_label.text
	tip_proton.text = Localizer.translate_plural("REFERENCE_PD_PROTON", element, element)
	var tmp: int = ElementCell.get_metallicity(element)
	tip_metal.visible = tmp == ElementCell.Metallicity.METAL
	tip_metalloid.visible = tmp == ElementCell.Metallicity.METALLOID
	tip_nonmetal.visible = tmp == ElementCell.Metallicity.NONMETAL
	tmp = ElementCell.phase_at_stp(element)
	tip_solid.visible = tmp == ElementCell.Phase.SOLID
	tip_liquid.visible = tmp == ElementCell.Phase.LIQUID
	tip_gas.visible = tmp == ElementCell.Phase.GAS
	
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
