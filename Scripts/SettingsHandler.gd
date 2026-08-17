extends Node
class_name SettingsHandler

static var do_formatting: bool = true
static var truncate_message_size: int = 63
static var preferred_callsign: int = -1
static var font_size: int = 18
static var image_default: bool = false
# godot does not have a Set datatype. lame!
static var opened_channels: Array = []
static var websocket_address: String = Main.DSCR_URL
static var theme_color: int = 57
static var master_volume: float = 1.0

static func initialize() -> void:
	# Setting names kept in PascalCase to keep backwards compatibility
	# also for some reason TMfDS uses PascalCase too. blegh.
	do_formatting = SaveSystem.settings.get_or_add("DoFormatting", do_formatting)
	image_default = SaveSystem.settings.get_or_add("ImageDefault", image_default)
	truncate_message_size = SaveSystem.settings.get_or_add("TruncateMessageSize", truncate_message_size)
	preferred_callsign = SaveSystem.settings.get_or_add("PreferredCallsign", preferred_callsign)
	font_size = SaveSystem.settings.get_or_add("FontSize", font_size)
	opened_channels = SaveSystem.settings.get_or_add("OpenedChannels", []).map(func (a): return int(a))
	websocket_address = SaveSystem.settings.get_or_add("WebsocketAddress", Main.DSCR_URL)
	theme_color = SaveSystem.settings.get_or_add("ThemeColor", theme_color)
	master_volume = SaveSystem.settings.get_or_add("MasterVolume", master_volume)
	evaluate_volume()

static func evaluate_volume() -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		master_volume * 0.667
	)
	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("Master"),
		master_volume <= 0.01
	)

static func save() -> void:
	SaveSystem.save_settings()

static func export() -> void:
	SaveSystem.settings.set("DoFormatting", do_formatting)
	SaveSystem.settings.set("ImageDefault", image_default)
	SaveSystem.settings.set("TruncateMessageSize", truncate_message_size)
	SaveSystem.settings.set("PreferredCallsign", preferred_callsign)
	SaveSystem.settings.set("FontSize", font_size)
	SaveSystem.settings.set("OpenedChannels", opened_channels)
	SaveSystem.settings.set("WebsocketAddress", websocket_address)
	SaveSystem.settings.set("ThemeColor", theme_color)
	SaveSystem.settings.set("MasterVolume", master_volume)
