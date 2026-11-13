extends TabContainer

func _ready():
	current_tab = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab_dictionary"):
		current_tab = 0
		accept_event()
		return
	if event.is_action_pressed("tab_users"):
		current_tab = 1
		accept_event()
		return
	if event.is_action_pressed("tab_settings"):
		current_tab = 2
		accept_event()
		return
