extends Node
class_name SettingsHandler

static var do_formatting: bool = true
static var truncate_message_size: int = 63
static var preferred_callsign: int = -1
static var font_size: int = 18
static var image_default: bool = false

static func initialize() -> void:
	# Setting names kept in PascalCase to keep backwards compatibility
	# also for some reason TMfDS uses PascalCase too. blegh.
	do_formatting = SaveSystem.settings.get_or_add("DoFormatting", true)
	image_default = SaveSystem.settings.get_or_add("ImageDefault", false)
	truncate_message_size = SaveSystem.settings.get_or_add("TruncateMessageSize", 64)
	preferred_callsign = SaveSystem.settings.get_or_add("PreferredCallsign", -1)
	font_size = SaveSystem.settings.get_or_add("FontSize", 18)

static func save() -> void:
	SaveSystem.save_settings()

static func export() -> void:
	SaveSystem.settings.set("DoFormatting", do_formatting)
	SaveSystem.settings.set("ImageDefault", image_default)
	SaveSystem.settings.set("TruncateMessageSize", truncate_message_size)
	SaveSystem.settings.set("PreferredCallsign", preferred_callsign)
	SaveSystem.settings.set("FontSize", font_size)
