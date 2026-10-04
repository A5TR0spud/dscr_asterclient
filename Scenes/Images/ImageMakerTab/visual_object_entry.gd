extends VBoxContainer
class_name VisualObjectEntry

enum ObjType {
	SPHERE,
	CUBE,
}

var type: ObjType = ObjType.SPHERE
var x: float = 0
var y: float = 0
var z: float = 0
var color: int = 57
var radius: float = 1

signal hear_my_plea(v: VisualObjectEntry)

@onready var color_node: ColorRect = $HBoxContainer/ColorRect
@onready var select_label: Label = $HBoxContainer/SelectLabel

func _ready():
	refresh()
	Main.instance.localization_reload.connect(refresh)

func refresh():
	var s: String
	match type:
		ObjType.SPHERE:
			s = Localizer.translate("COMPOSITOR_SPHERE", [color, radius])
		ObjType.CUBE:
			s = Localizer.translate("COMPOSITOR_CUBE", [color, radius])
	select_label.text = s
	color_node.color = VisualizeNode.calculate_color(color)

func _on_select_button_pressed():
	hear_my_plea.emit(self)

func _on_down_button_pressed():
	_move_relative(1)

func _on_up_button_pressed():
	_move_relative(-1)

func _move_relative(delta: int):
	get_parent().move_child(self, get_index() + delta)
