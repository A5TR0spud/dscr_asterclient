class_name NicknamesHandler

static func set_nick(callsign, name: String) -> bool:
	if callsign is int:
		callsign = Main.base_10_to_callsign(callsign)
	
	if name.is_empty() and not SaveSystem.nicknames.has(callsign):
		return false
	
	if SaveSystem.nicknames.has(callsign) and SaveSystem.nicknames[callsign] == name:
		return false
	
	if name.is_empty():
		SaveSystem.nicknames.erase(callsign)
	else:
		SaveSystem.nicknames.set(callsign, name)
	SaveSystem.save_nicknames()
	Main.on_nicknames_reload()
	return true

static func get_nick(callsign) -> String:
	if callsign is int:
		callsign = Main.base_10_to_callsign(callsign)
	return SaveSystem.nicknames.get(callsign, "")

static func get_all_nicknames() -> Array[int]:
	var o: Array[int] = []
	for i:String in SaveSystem.nicknames.keys():
		if get_nick(i).is_empty():
			continue
		o.append(64 * 8 * int(i[0]) + 64 * int(i[1]) + 8 * int(i[2]) + int(i[3]))
	return o
