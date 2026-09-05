extends Node
class_name SettingsHandler

static var do_formatting: bool = true
static var truncate_message_size: int = 63
static var preferred_callsign: int = -1
static var font_size: int = 18
static var image_default: bool = false
static var opened_channels: Array = []
static var theme_color: int = 57
static var master_volume: float = 1.0
static var img_invert_yaw: bool = false
static var img_invert_pitch: bool = false
static var img_invert_zoom: bool = false
static var do_bbcode: bool = false
static var use_at_undef: bool = true
static var language: String = ""
static var websocket_address: String = Main.DSCR_URL
static var websocket_addresses: Array = [Main.DSCR_URL]

static func validate_and_set_language(code: String = language):
	if code not in ["m0", "en"]:
		LocaleMenu.open()
		return
	language = code
	TranslationServer.set_locale(language)
	Main.on_localization_reload()
	save()

static func delete_wss(address: String) -> void:
	if websocket_addresses.has(address):
		websocket_addresses.erase(address)
		save()

static func change_wss(old_address: String, new_address: String) -> void:
	var idx: int = websocket_addresses.find(old_address)
	if idx >= 0:
		websocket_addresses[idx] = new_address
		save()

static func add_wss(address: String) -> void:
	websocket_addresses.append(address)
	save()

static func initialize() -> void:
	# Setting names kept in PascalCase to keep backwards compatibility
	# also for some reason TMfDS uses PascalCase too. blegh.
	do_formatting = SaveSystem.settings.get_or_add("DoFormatting", do_formatting)
	image_default = SaveSystem.settings.get_or_add("ImageDefault", image_default)
	truncate_message_size = SaveSystem.settings.get_or_add("TruncateMessageSize", truncate_message_size)
	preferred_callsign = SaveSystem.settings.get_or_add("PreferredCallsign", preferred_callsign)
	font_size = SaveSystem.settings.get_or_add("FontSize", font_size)
	opened_channels = SaveSystem.settings.get_or_add("OpenedChannels", []).map(func (a): return int(a))
	theme_color = SaveSystem.settings.get_or_add("ThemeColor", theme_color)
	master_volume = SaveSystem.settings.get_or_add("MasterVolume", master_volume)
	evaluate_volume()
	img_invert_pitch = SaveSystem.settings.get_or_add("img_invert_pitch", img_invert_pitch)
	img_invert_yaw = SaveSystem.settings.get_or_add("img_invert_yaw", img_invert_yaw)
	img_invert_zoom = SaveSystem.settings.get_or_add("img_invert_zoom", img_invert_zoom)
	do_bbcode = SaveSystem.settings.get_or_add("do_bbcode", do_bbcode)
	use_at_undef = SaveSystem.settings.get_or_add("use_at_undef", use_at_undef)
	language = SaveSystem.settings.get_or_add("language", "")
	validate_and_set_language.call_deferred()
	websocket_address = SaveSystem.settings.get_or_add("WebsocketAddress", websocket_address)
	websocket_addresses = SaveSystem.settings.get_or_add("wss_addresses", websocket_addresses)
	if websocket_address not in websocket_addresses:
		websocket_addresses.append(websocket_address)
	if Main.DSCR_URL not in websocket_addresses:
		websocket_addresses.append(Main.DSCR_URL)

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
	SaveSystem.settings.set("ThemeColor", theme_color)
	SaveSystem.settings.set("MasterVolume", master_volume)
	SaveSystem.settings.set("img_invert_pitch", img_invert_pitch)
	SaveSystem.settings.set("img_invert_zoom", img_invert_zoom)
	SaveSystem.settings.set("img_invert_yaw", img_invert_yaw)
	SaveSystem.settings.set("do_bbcode", do_bbcode)
	SaveSystem.settings.set("use_at_undef", use_at_undef)
	SaveSystem.settings.set("language", language)
	SaveSystem.settings.set("wss_addresses", websocket_addresses)
	SaveSystem.settings.set("WebsocketAddress", websocket_address)
