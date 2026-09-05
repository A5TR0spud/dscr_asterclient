extends Node
class_name LibraryHandler

static func has_transmission(trx_name: String) -> bool:
	return SaveSystem.library.has(trx_name)

static func set_transmission(trx_name: String, msg: Array):
	SaveSystem.library.set(trx_name, msg)
	Main.on_library_reload()
	SaveSystem.save_library()

static func get_transmission(trx_name: String) -> Array:
	return (SaveSystem.library.get(trx_name, []) as Array).map(func(a): return int(a))

static func forget_transmission(trx_name: String):
	SaveSystem.library.erase(trx_name)
	Main.on_library_reload()
	SaveSystem.save_library()

static func get_all_transmissions() -> Array[String]:
	return SaveSystem.library.keys()
