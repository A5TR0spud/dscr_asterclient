extends Button
class_name UnknownSignalButton

var sig: int = 0

func _pressed():
	DictEditMenu.open(sig)
