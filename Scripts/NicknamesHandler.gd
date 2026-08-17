class_name NicknamesHandler

static func set_nick(callsign, name: String) -> void:
	if callsign is int:
		callsign = Main.base_10_to_callsign(callsign)
	if name.is_empty():
		SaveSystem.nicknames.erase(callsign)
	else:
		SaveSystem.nicknames.set(callsign, name)
	SaveSystem.save_nicknames()
	Main.on_nicknames_reload()

static func get_nick(callsign) -> String:
	if callsign is int:
		callsign = Main.base_10_to_callsign(callsign)
	return SaveSystem.nicknames.get(callsign, "")
