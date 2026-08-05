extends TabContainer

func _ready():
	Main.instance.ReloadDict.connect(Refresh)
	current_tab = 0

func Refresh():
	self.set("tab_0/title", DictionaryHandler.GetOrDefaultSignalName(-246))
	self.set("tab_1/title", DictionaryHandler.GetOrDefaultSignalName(-130))
	self.set("tab_2/title", DictionaryHandler.GetOrDefaultSignalName(-241))
