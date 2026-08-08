extends Node
class_name SettingsHandler

static var DoFormatting: bool = true
static var TruncateMessageSize: int = 63
static var PreferredCallsign: int = -1
static var FontSize: int = 18
static var ImageDefault: bool = false

static func Initialize() -> void:
	DoFormatting = SaveSystem.Settings.get_or_add("DoFormatting", true)
	ImageDefault = SaveSystem.Settings.get_or_add("ImageDefault", false)
	TruncateMessageSize = SaveSystem.Settings.get_or_add("TruncateMessageSize", 64)
	PreferredCallsign = SaveSystem.Settings.get_or_add("PreferredCallsign", -1)
	FontSize = SaveSystem.Settings.get_or_add("FontSize", 18)

static func Save() -> void:
	SaveSystem.SaveSettings()

static func Export() -> void:
	SaveSystem.Settings.set("DoFormatting", DoFormatting)
	SaveSystem.Settings.set("ImageDefault", ImageDefault)
	SaveSystem.Settings.set("TruncateMessageSize", TruncateMessageSize)
	SaveSystem.Settings.set("PreferredCallsign", PreferredCallsign)
	SaveSystem.Settings.set("FontSize", FontSize)
