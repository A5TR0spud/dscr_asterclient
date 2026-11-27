class_name SignalRendering

# Helper method for calculating the sphere colors
# Visual Object colors are evaluated on a gradient [0, 64] to get RGB values. The full gradient linearly blends between keys. In the game, the keys are: 
# 0 - #FF5800  0.00 red-orange
# 1 - #BBFF00  7.11 yellow-green
# 2 - #00CDFF 14.22 cyan
# 3 - #0084FF 21.33 light blue
# 4 - #4D00FF 28.44 blurple
# 5 - #FB39FF 35.56 bubblegum pink
# 6 - #FF0FD7 42.67 hot pink
# 7 - #484848 49.78 black
# 8 - #636363 56.89 grey
# 9 - #FFFFFF 64.00 white
# Code thanks to @elnico56 in discord!!!!
# Code adapted from https://github.com/dixonary/mfds-server/blob/0d359cef41a64cfe2bddbacb12898f066fa099b8/public/mfds.js#L1009-L1034
const COLORS: Array = [
	"FF5800", "BBFF00", "00CDFF", "0084FF", "4D00FF",
	"FB39FF", "FF0FD7", "484848", "636363", "FFFFFF"
];
static func calculate_color(value: int) -> Color:
	if value >= 65 and value <= 128 and DictionaryHandler.support_dscr:
		value -= 65
		var r: float
		var g: float
		var b: float
		const _col: PackedFloat32Array = [0.1, 0.5, 0.75, 1]
		r = _col[(value >> 4) % 4]
		g = _col[(value >> 2) % 4]
		b = _col[value % 4]
		if value == 0:
			r += 0.1
			g += 0.1
			b += 0.1
		return Color(r, g, b)
	if value < 0 or value > 64:
		return Color.TRANSPARENT
	value = clampi(value, 0, 64)
	var n: float = value / 64.0 * (COLORS.size() - 1)
	var lo = floor(n)
	var hi = ceil(n)
	return lerp(Color(COLORS[lo]), Color(COLORS[hi]), fmod(n, 1))

static func coord_m0_to_godot(godot: Vector3) -> Vector3:
	return Vector3(godot.x, godot.z, -godot.y)
static func coord_godot_to_m0(godot: Vector3) -> Vector3:
	return Vector3(godot.x, -godot.z, godot.y)

class VisualData:
	extends Resource
	@export var objects: Array[VisualObject]
	
	func export_to_signals(no_trailing_commas: bool = false) -> String:
		return ""
	
	func _parse_visual_object(parser: TransmissionParser) -> void:
		var wip: VisualObject = VisualObject.new()
		if DictionaryHandler.support_dscr and parser.try_consume(SigDB.CUBE) and DictionaryHandler.contains_signal(SigDB.CUBE):
			wip.type = SigDB.CUBE
		elif DictionaryHandler.support_dscr and parser.try_consume(SigDB.BOX) and DictionaryHandler.contains_signal(SigDB.BOX):
			wip.type = SigDB.BOX
		elif DictionaryHandler.support_dscr and parser.try_consume(SigDB.RENDER_LINE) and DictionaryHandler.contains_signal(SigDB.RENDER_LINE):
			wip.type = SigDB.RENDER
		else:
			parser.try_consume(SigDB.RENDER_SPHERE)
			wip.type = SigDB.RENDER_SPHERE

		wip.pos.x = parser.read_number()
		parser.expect(SigDB.SEP)
		wip.pos.y = parser.read_number()
		parser.expect(SigDB.SEP)
		wip.pos.z = parser.read_number()
		parser.expect(SigDB.SEP)
		var v0: float = parser.read_number()
		parser.expect(SigDB.SEP)
		var v1: float = parser.read_number()
		if wip.type == SigDB.BOX:
			wip.delta.x = v0
			wip.delta.y = v1
			parser.expect(SigDB.SEP)
			var v2: float = parser.read_number()
			wip.delta.z = v2
			parser.expect(SigDB.SEP)
			wip.color = int(parser.read_number())
		elif wip.type == SigDB.RENDER_LINE:
			wip.delta.x = v0
			wip.delta.y = v1
			parser.expect(SigDB.SEP)
			wip.delta.z = parser.read_number()
			parser.expect(SigDB.SEP)
			wip.color = int(parser.read_number())
		else:
			wip.delta = Vector3(v0, v0, v0)
			wip.color = int(v1)
		parser.try_consume(SigDB.SEP)
		objects.append(wip)

static func check_message(message0: Array) -> Array[VisualData]:
	var out: Array[VisualData] = []
	var wip: VisualData = VisualData.new()
	var message: Array[int] = []
	for u in message0:
		if u is int:
			message.append(u)
		else:
			return []
	var parser = TransmissionParser.new(message)
	while not parser.is_at_end():
		if not parser.skip_to(SigDB.RENDER): return out
		parser.expect(SigDB.RENDER)
		var pos := parser.save_state()
		parser.read_group_items(wip._parse_visual_object)

		if parser.has_error():
			print(parser.get_error_message())
			parser.restore_state(pos, true)
			wip = VisualData.new()
			continue
		
		if not wip.objects.is_empty():
			out.append(wip)
			wip = VisualData.new()

	return out

class VisualObject:
	extends Resource
	@export var pos: Vector3
	@export var delta: Vector3
	@export var color: int
	@export var type: int
