@tool
extends PanelContainer
class_name ElementCell

@export var element: int = 1:
	set(value):
		element = value
		if is_instance_valid(proton_label):
			proton_label.text = str(value)

@onready var proton_label: Label = $MarginContainer/VBoxContainer/Head/ProtonCt
@onready var symbol_label: Label = $MarginContainer/VBoxContainer/Symbol
@onready var name_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/Name
@onready var name_scroll: HScrollBar = $MarginContainer/VBoxContainer/ScrollContainer.get_h_scroll_bar()
@onready var edger: Timer = $EdgeTimer

var _pd_table: PeriodicTable

func _ready():
	proton_label.text = str(element)
	if Engine.is_editor_hint():
		return
	_pd_table = get_parent() if get_parent() is PeriodicTable else null
	if _pd_table:
		_pd_table.focus.connect(_on_pd_focus)
	var l: LocaleNode = LocaleNode.new()
	l.translations = {"text": str("REFERENCE_ELEMENT_SYMBOL_",element)}
	symbol_label.add_child(l)
	l = LocaleNode.new()
	l.translations = {"text": str("REFERENCE_ELEMENT_NAME_",element)}
	name_label.add_child(l)

func hover_refresh(elm: int, start: bool):
	if element == elm and start:
		modulate.a = 1
		return
	if element != elm and start:
		modulate.a = 0.5
		return
	if element == elm and not start:
		modulate.a = 1
	modulate.a = 0.5 if element != elm and start else 1.0

var _bright: bool = true

func _on_pd_focus(elem: int):
	_bright = elem <= 0 or element == elem

var going_right: bool = true
func _process(delta):
	if _bright:
		modulate.a = min(modulate.a + delta * 3.0, 1)
	else:
		modulate.a = max(modulate.a - delta * 3.0, 0.5)
	
	if not edger.is_stopped():
		return
	if not going_right:
		delta *= -1
	name_scroll.value += delta * 6.0
	if name_scroll.value >= name_scroll.max_value - name_scroll.page or name_scroll.value <= 0:
		going_right = not going_right
		edger.start(2 * Main.HE6_HALF_LIFE)

enum Metallicity {
	METAL = 0,
	METALLOID = 1,
	NONMETAL = 2,
	UNKNOWN = -1
}

enum Phase {
	SOLID = 0,
	LIQUID = 1,
	GAS = 2,
	UNKNOWN = -1
}

static func phase_at_stp(protons: int) -> Phase:
	if protons == 80 or protons == 35:
		return Phase.LIQUID
	if protons <= 2:
		return Phase.GAS
	if protons <= 6:
		return Phase.SOLID
	if protons <= 10:
		return Phase.GAS
	if protons <= 16:
		return Phase.SOLID
	if protons <= 18:
		return Phase.GAS
	if protons <= 34:
		return Phase.SOLID
	if protons == 36 or protons == 54 or protons == 86:
		return Phase.GAS
	if protons <= 108:
		return Phase.SOLID
	return Phase.UNKNOWN

static func no_stable_isotopes(protons: int) -> bool:
	if protons == 43 or protons == 61:
		return true
	return protons >= 84

static func get_metallicity(protons: int) -> Metallicity:
	if protons <= 2:
		return Metallicity.NONMETAL
	if protons <= 4:
		return Metallicity.METAL
	if protons == 5:
		return Metallicity.METALLOID
	if protons <= 10:
		return Metallicity.NONMETAL
	if protons <= 13:
		return Metallicity.METAL
	if protons == 14:
		return Metallicity.METALLOID
	if protons <= 18:
		return Metallicity.NONMETAL
	if protons <= 31:
		return Metallicity.METAL
	if protons <= 33:
		return Metallicity.METALLOID
	if protons <= 36:
		return Metallicity.NONMETAL
	if protons <= 50:
		return Metallicity.METAL
	if protons <= 52:
		return Metallicity.METALLOID
	if protons <= 54:
		return Metallicity.NONMETAL
	if protons <= 84:
		return Metallicity.METAL
	if protons == 85:
		return Metallicity.METALLOID
	if protons == 86:
		return Metallicity.NONMETAL
	if protons <= 108:
		return Metallicity.METAL
	return Metallicity.UNKNOWN

#ALL KNOWN METAL
#[ ELEMENT 3, 4, 11 ETC 13, 19 ETC 31, 37 ETC 50, 55 ETC 84, 87 ETC 108 ]
#; ;
#ALL KNOWN NONMETAL
#[ ELEMENT 1, 2, 6 ETC 10, 15 ETC 18, 34 ETC 36, 53, 54, 86 ]
#; ;
#ALL KNOWN METALLOID
#[ ELEMENT 5, 14, 32, 33, 51, 52, 85 ]

func _on_mouse_entered():
	if Input.get_mouse_button_mask() > 0 or not _pd_table:
		return
	_pd_table.on_hover_start(self)

func _on_mouse_exited():
	if not _pd_table:
		return
	_pd_table.on_hover_end(self)
