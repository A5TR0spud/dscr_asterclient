extends TabContainer

func _ready():
	Main.instance.reload_dict.connect(refresh)
	current_tab = 0

func refresh():
	set_tab_title(0, DictionaryHandler.get_or_default_signal_name(-42))
	set_tab_title(1, DictionaryHandler.get_or_default_signal_name(-130))
	set_tab_title(2, DictionaryHandler.get_or_default_signal_name(-241))
