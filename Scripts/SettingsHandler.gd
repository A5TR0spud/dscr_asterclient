extends Node
class_name SettingsHandler

static var DoFormatting: bool = true
static var TruncateMessageSize: int = 63
static var PreferredCallsign: int = -1

static func Initialize() -> void:
	DoFormatting = SaveSystem.Settings.get_or_add("DoFormatting", true)
	TruncateMessageSize = SaveSystem.Settings.get_or_add("TruncateMessageSize", 64)
	PreferredCallsign = SaveSystem.Settings.get_or_add("PreferredCallsign", -1)

static func Save() -> void:
	SaveSystem.SaveSettings()

static func Export() -> void:
	SaveSystem.Settings.set("DoFormatting", DoFormatting)
	SaveSystem.Settings.set("TruncateMessageSize", TruncateMessageSize)
	SaveSystem.Settings.set("PreferredCallsign", PreferredCallsign)
