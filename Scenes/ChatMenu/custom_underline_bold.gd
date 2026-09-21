extends Node
class_name CustomEffectsInstallerNode
# harvested from https://forum.godotengine.org/t/is-it-possible-to-customize-the-styling-of-the-underline-in-a-richtext-label/132709/3

@onready var rich_text_label: RichTextLabel = self.get_parent()

var custom_lined_effect = LinedEffect.new()

func _ready() -> void:
	rich_text_label.install_effect(custom_lined_effect)
	rich_text_label.draw.connect(_draw)
	rich_text_label.finished.connect(func():
		custom_lined_effect.offsets.clear()
	)

func _draw() -> void:
	for offset in custom_lined_effect.offsets:
		var c := Color(offset.color)
		c.a *= 0.8
		var s: Vector2i = Vector2i(offset.start)
		var h: int = offset.height
		var e: Vector2i = Vector2i(offset.endx+1, s.y)
		if offset.u:
			var off := Vector2i(0, 4)
			rich_text_label.draw_line(
				s + off, e + off,
				c, 2
			)
		if offset.s:
			@warning_ignore("integer_division")
			var off := Vector2i(0, -h / 2 + 1)
			rich_text_label.draw_line(
				s + off, e + off,
				c, 2
			)

class LinedEffect extends RichTextEffect:
	var bbcode: String = "su2"

	var last_start_range: int = -1

	var offsets = []
	static var ts = TextServerManager.get_primary_interface()
	func _process_custom_fx(char_fx: CharFXTransform) -> bool:
		var start_range = char_fx.range.x
		
		var size: Vector2 = Vector2(SettingsHandler.font_size, SettingsHandler.font_size) * 0.5
		size = ts.font_get_glyph_size(char_fx.font, Vector2i(size), char_fx.glyph_index)
		
		if last_start_range > start_range:
			offsets.clear()
		
		if (
			char_fx.relative_index == 0 or
			(offsets.size() > 0 and offsets.back().start.y != char_fx.transform.origin.y)
		):
			offsets.append({
				"start": char_fx.transform.origin,
				"height": size.y,
				"endx": char_fx.transform.origin.x + size.x,
				"color": char_fx.color,
				"u": char_fx.env.get("u", false),
				"s": char_fx.env.get("s", false)
			})
		elif offsets.size() > 0:
			offsets.back().endx = char_fx.transform.origin.x + size.x

		last_start_range = start_range

		return false
