extends Node
class_name ThemeManager

static var new_theme = preload("uid://c0reghmcwiqpy")
# big panels
static var panel_style = preload("uid://dcmofilgg82h2")
static var text_edit_style = preload("uid://chd3p7o56iqny")
static var code_edit_style = preload("uid://cem7hlj42ccbd")
static var code_autocomplete_style = preload("uid://bca1ief1qema3")
# Button
static var outline_style = preload("uid://2awcl5rgmg3n")
static var hover_press_style = preload("uid://d4lo7uvlc7obp")
static var press_style = preload("uid://da5ge6d3pcwlc")
# HScrollBar
static var grabber_style = preload("uid://6bx0nrubukdd")
static var grabber_pressed_style = preload("uid://d2w74s2vi088d")
static var grabber_back_style = preload("uid://bc7c1ue25eq6g")
static var v_grabber_back_style = preload("uid://8g63ltkd03h1")
# Tabbers
static var tab_selected = preload("uid://8mg0wvheihvx")
static var tab_unselected = preload("uid://bcpf14e281kyl")
static var tab_but_selected = preload("uid://bud12urn6xcjr")
static var tab_but_unselected = preload("uid://10juafvr3ky1")
# Seps
static var h_sep = preload("uid://dgjcahl47q10n")
static var v_sep = preload("uid://db3k5eiovgegq")
static var h_split = preload("uid://b1t3fn13p4807")

static var old_color: int = -1

static func set_font_size(size: int = -1) -> void:
	if size < 12 or size > 32:
		size = SettingsHandler.font_size
	if size < 12 or size > 32:
		size = 18
	new_theme.default_font_size = size
	if SettingsHandler.font_size != size:
		SettingsHandler.font_size = size
		SettingsHandler.save()

static func set_theme_color(col: int = -1) -> void:
	if col < 0 or col > 64:
		col = SettingsHandler.theme_color
	if col < 0 or col > 64:
		col = 57
	if SettingsHandler.theme_color != col:
		SettingsHandler.theme_color = col
		SettingsHandler.save()
	if old_color == col:
		return
	old_color = col
	
	var new_color: Color = VisualizeNode.calculate_color(col)
	var red_correction: float = 0
	if col == 0:
		red_correction = 1
	elif col == 1:
		red_correction = 0.5
	if red_correction > 0:
		new_color.r += 0.15 * red_correction
		new_color.g *= 1 - 0.125 * red_correction
		new_color.b += 0.125 * red_correction
	if col == 4 or col == 5:
		new_color.r += new_color.g * 0.1
		new_color.g += new_color.r * 0.09
	var green_correction: float = 0
	if col >= 7 and col <= 9:
		green_correction = (col - 6) * 0.333
	if col == 10:
		green_correction = 0.5
	green_correction *= 0.5
	if green_correction > 0:
		new_color.r *= 1.0 - green_correction
		new_color.g = max(green_correction * 0.7, new_color.g)
		new_color.b *= 1.0 - green_correction
		new_color *= 1.0 - (green_correction * 0.5)
	var ratio: Color = new_color * 0.5 + Color(0.7, 0.7, 0.7)
	
	
	# backgrounds
	new_color.r8 -= 62
	new_color.g8 -= 62
	new_color.b8 -= 62
	new_color *= 0.1
	new_color.a8 = 255
	if col < 50:
		new_color.s *= 1.2
		new_color.v *= 0.4
	panel_style.bg_color = new_color
	code_autocomplete_style.bg_color = new_color
	# edit boxes
	new_color.r += 0.1 * ratio.r
	new_color.g += 0.1 * ratio.g
	new_color.b += 0.1 * ratio.b
	text_edit_style.bg_color = new_color
	code_edit_style.bg_color = new_color
	grabber_back_style.bg_color = new_color
	v_grabber_back_style.bg_color = new_color
	# dark outline
	new_color.r += 0.2 * ratio.r
	new_color.g += 0.2 * ratio.g
	new_color.b += 0.2 * ratio.b
	press_style.border_color = new_color
	tab_unselected.border_color = new_color
	tab_but_unselected.border_color = new_color
	# normal outline
	new_color.r += 0.2 * ratio.r
	new_color.g += 0.2 * ratio.g
	new_color.b += 0.2 * ratio.b
	outline_style.border_color = new_color
	tab_selected.border_color = new_color
	tab_but_selected.border_color = new_color
	panel_style.border_color = new_color
	code_autocomplete_style.border_color = new_color
	h_sep.color = new_color
	v_sep.color = new_color
	h_split.bg_color = new_color
	h_sep.color.a = 0.5
	v_sep.color.a = 0.5
	h_split.bg_color.a = 0.5
	grabber_pressed_style.bg_color = new_color
	# light outline
	new_color.r += 0.1 * ratio.r
	new_color.g += 0.1 * ratio.g
	new_color.b += 0.1 * ratio.b
	grabber_style.bg_color = new_color
	hover_press_style.border_color = new_color
