extends TabContainer

func _ready():
	Main.instance.reload_dict.connect(refresh)
	current_tab = 0

func refresh():
	self.set("tab_0/title", DictionaryHandler.get_or_default_signal_name(-42))
	self.set("tab_1/title", DictionaryHandler.get_or_default_signal_name(-130))
	self.set("tab_2/title", DictionaryHandler.get_or_default_signal_name(-241))
